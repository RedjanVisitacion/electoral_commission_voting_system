import 'package:flutter_project/auth/login_screen.dart';
import 'package:flutter_project/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/auth/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Sign Out",
              onPressed: () async {
                try {
                  await auth.signout();
                  if (!context.mounted) return;
                  goToLogin(context);
                } catch (e) {
                  if (!context.mounted) return;
                  final msg = e is Exception ? e.toString() : 'Sign out error';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg.replaceFirst('Exception: ', ''))),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
}
