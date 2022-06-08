import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meekath/model/user_model.dart';
import 'package:meekath/view_model/admin_view_model.dart';
import 'package:meekath/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../repo/firebase_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool? _isLoading;

  bool? get isLoading => _isLoading;

  void setLoading(bool? loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void startPayment(
      BuildContext context, String money, UserModel user, bool isAdmin) async {
    // start loading
    setLoading(true);
    // upload payment to firebase
    if (money != "") {
      int amount = int.parse(money);
      await FirebaseService.uploadPayment(amount, user.docId);
      // Refresh all data
      if (isAdmin) {
        Provider.of<AdminProvider>(context, listen: false).initData();
      } else {
        UserProvider provider =
            Provider.of<UserProvider>(context, listen: false);

        provider.initData(provider.user.username);
      }
      // payment finished show checkmark
      setLoading(false);
      //after few seconds show payment screen
      await Future.delayed(const Duration(seconds: 3));
      setLoading(null);
      notifyListeners();
    }
  }
}
