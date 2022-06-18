import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meekath/model/payment_model.dart';
import 'package:meekath/model/user_model.dart';
import 'package:meekath/service/analytics_service.dart';

import '../model/login_response.dart';
import '../model/user_analytics_model.dart';

class FirebaseService {
  static Future<LoginResponse> uploadUser(UserModel user) async {
    CollectionReference<Map<String, dynamic>> users =
        FirebaseFirestore.instance.collection('users');
    // Check user is already exists
    LoginResponse alreadyExists = await checkUserIsAlreadyExists(user);
    if (!alreadyExists.isSuccessful) {
      return alreadyExists;
    }
    // Then uploading user to firebase
    await users.add({
      'name': user.name,
      'phoneNumber': user.phoneNumber,
      'username': user.username,
      'password': user.password,
      'monthlyPayment': user.monthlyPayment,
    });
    return LoginResponse(
        isSuccessful: true, message: 'Logged in', username: user.username);
  }

  static Future<bool> uploadPayment(PaymentModel payment) async {
    CollectionReference<Map<String, dynamic>> payments =
        FirebaseFirestore.instance.collection('transactions');

    payments.add({
      'userId': payment.userDocId,
      'amount': payment.amount,
      // DateTime convert to timestamp
      'date': Timestamp.fromDate(payment.dateTime),
      'verify': payment.verify,
    });
    return false;
  }

  static Future updatePayment(String docId, int status) async {
    CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection('transactions');
    await collection.doc(docId).update({
      'verify': status,
    });
  }

  static Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    List<PaymentModel> allPayments = await getAllPayments();

    CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot<Map<String, dynamic>> userCollection = await collection.get();
    for (var user in userCollection.docs) {
      // Payments Details
      List<PaymentModel> payments = [];

      for (var payment in allPayments) {
        if (user.id == payment.userDocId) {
          payments.add(payment);
        }
      }

      UserAnalyticsModel analytics = AnalyticsService.getUserAnalytics(
          user.get('monthlyPayment'), payments);

      users.add(UserModel(
        docId: user.id,
        name: user.get('name'),
        phoneNumber: user.get('phoneNumber'),
        username: user.get('username'),
        password: user.get('password'),
        monthlyPayment: user.get('monthlyPayment'),
        analytics: analytics,
        payments: payments,
      ));
    }
    return users;
  }

  static Future<UserModel?> getUser(
      String username, bool needAllDetails) async {
    CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot<Map<String, dynamic>> users = await collection.get();

    for (var user in users.docs) {
      if (user.get('username') == username) {
        UserAnalyticsModel? analytics;
        List<PaymentModel> payments = [];

        // if need user payment details
        if (needAllDetails) {
          List<PaymentModel> allPayments = await getAllPayments();

          for (var payment in allPayments) {
            if (user.id == payment.userDocId) {
              payments.add(payment);
            }
          }
          analytics = AnalyticsService.getUserAnalytics(
              user.get('monthlyPayment'), payments);
        }

        // returning user data
        return UserModel(
          docId: user.id,
          name: user.get('name'),
          phoneNumber: user.get('phoneNumber'),
          username: user.get('username'),
          password: user.get('password'),
          monthlyPayment: user.get('monthlyPayment'),
          analytics: analytics,
          payments: payments,
        );
      }
    }
    return null;
  }

  static Future<List<PaymentModel>> getAllPayments() async {
    List<PaymentModel> payments = [];
    CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection('transactions');

    QuerySnapshot<Map<String, dynamic>> paymentCollection =
        await collection.get();

    for (var payment in paymentCollection.docs) {
      payments.add(PaymentModel(
        docId: payment.id,
        userDocId: payment.get('userId'),
        amount: payment.get('amount'),
        verify: payment.get('verify'),
        // Timestamp convert to datetime
        dateTime: (payment.get('date') as Timestamp).toDate(),
      ));
    }
    return payments;
  }

  static Future<LoginResponse> checkUserIsAlreadyExists(UserModel user) async {
    QuerySnapshot<Map<String, dynamic>> users =
        await FirebaseFirestore.instance.collection('users').get();

    for (var _user in users.docs) {
      if (_user.get('username') == user.username) {
        return LoginResponse(
            isSuccessful: false, message: 'Username already exists');
      }
      if (_user.get('phoneNumber') == user.phoneNumber) {
        return LoginResponse(
            isSuccessful: false, message: 'Phone number already exists');
      }
    }
    return LoginResponse(isSuccessful: true, message: "Success");
  }

  static Future<String> getAdminPassword() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('application')
            .doc('admin')
            .get();
    String password = documentSnapshot['password'];
    return password;
  }

  static Future<int> getLatestVersion() async {
    int version;
    DocumentSnapshot<Map<String, dynamic>>? doc = await FirebaseFirestore
        .instance
        .collection('application')
        .doc('version')
        .get();

    // check document exists ( avoiding null exceptions )
    if (doc.exists && doc.data()!.containsKey("version")) {
      // if document exists, fetch version in firebase
      try {
        version = doc['version'];
      } catch (e) {
        version = 0;
      }
    } else {
      // if document not exists, manually assign 0 ( avoiding null exceptions )
      version = 0;
    }

    return version;
  }
}
