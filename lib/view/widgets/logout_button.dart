import 'package:flutter/material.dart';
import 'package:meekath/view_model/login_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../screens/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 45,
      child: TextButton(
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20, color: primaryColor),
        ),
        onPressed: () {
          showDialog(context: context, builder: (_) => const LogoutDialog());
        },
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure ?'),
      actions: [
        ElevatedButton(
            onPressed: () async {
              // remove username in shared preferences
              Provider.of<LoginProvider>(context, listen: false)
                  .logout(context);
              // then, go to login screen
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false);
            },
            child: const Text('Logout'))
      ],
    );
  }
}
