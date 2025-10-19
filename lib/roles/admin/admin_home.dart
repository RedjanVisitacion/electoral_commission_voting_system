import 'package:flutter/material.dart';
import 'package:flutter_project/auth/auth_service.dart';
import 'package:flutter_project/auth/login_screen.dart';
import 'package:flutter_project/widgets/placeholder_page.dart';
import 'package:flutter_project/roles/admin/generate_qr_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _fullBtn(context, 'Generate QR Codes', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GenerateQrScreen()),
                );
              }),
              const SizedBox(height: 12),
              _fullBtn(context, 'Register Candidates', () => _open(context, 'Register Candidates')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Manage Voters', () => _open(context, 'Manage Voters')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Assign Computers', () => _open(context, 'Assign Computers')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Generate Reports', () => _open(context, 'Generate Reports')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Publish Results', () => _open(context, 'Publish Results')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await auth.signout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fullBtn(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }

  void _open(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceholderPage(title: title, description: '$title screen placeholder'),
      ),
    );
  }
}
