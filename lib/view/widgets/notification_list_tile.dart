import 'package:baitulmaal/model/user_payment.dart';
import 'package:baitulmaal/view/widgets/payment_dialog.dart';
import 'package:baitulmaal/view_model/admin_view_model.dart';
import 'package:baitulmaal/view_model/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/enums.dart';
import '../../view_model/payment_view_model.dart';

class NotificationListTile extends StatelessWidget {
  final int index;
  final UserPaymentModel userPayment;

  const NotificationListTile({
    Key? key,
    required this.index,
    required this.userPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userPayment.user.name,
                  style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Amount : ${userPayment.payment.amount}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Accept Button
                    ActionButton(
                      index: index,
                      text: 'Accept',
                      color: Colors.green,
                      icon: Icons.done,
                      status: PaymentStatus.accepted,
                      userPayment: userPayment,
                    ),
                    const Expanded(flex: 1, child: SizedBox()),
                    // Reject Button
                    ActionButton(
                      index: index,
                      text: 'Reject',
                      color: Colors.red,
                      icon: Icons.close,
                      status: PaymentStatus.rejected,
                      userPayment: userPayment,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () =>
              showDialog(context: context, builder: (ctx) => PaymentDialog(userPayment: userPayment, isAdmin: true)),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final int index;
  final String text;
  final Color color;
  final IconData icon;
  final PaymentStatus status;
  final UserPaymentModel userPayment;

  const ActionButton({
    Key? key,
    required this.index,
    required this.text,
    required this.color,
    required this.icon,
    required this.status,
    required this.userPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: SizedBox(
        height: 50,
        child: Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            splashColor: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                )
              ],
            ),
            onTap: () async {
              PaymentProvider paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
              AdminProvider adminProvider = Provider.of<AdminProvider>(context, listen: false);
              NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              if (notificationProvider.paymentNotVerifiedList.contains(userPayment)) {
                // Update payment in firebase
                paymentProvider.updatePayment(userPayment.payment.docId!, status);
                // Update all data's
                adminProvider.initData(notificationProvider.listKey.currentContext!);
                // animation
                notificationProvider.paymentNotVerifiedList.remove(userPayment);
                notificationProvider.listKey.currentState!.removeItem(
                  index,
                  (context, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: NotificationListTile(
                        index: index,
                        userPayment: userPayment,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
