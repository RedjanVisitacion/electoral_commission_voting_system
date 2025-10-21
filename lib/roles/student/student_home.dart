import 'package:flutter/material.dart';
import 'package:flutter_project/auth/auth_service.dart';
import 'package:flutter_project/auth/login_screen.dart';
import 'package:flutter_project/widgets/placeholder_page.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _fullBtn(context, 'Dashboard', () => _open(context, 'Dashboard')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Vote', () => _open(context, 'Vote')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Confirm Vote', () => _open(context, 'Confirm Vote')),
              const SizedBox(height: 12),
              _fullBtn(context, 'Print Receipt', () => _open(context, 'Print Receipt')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        final scheme = Theme.of(ctx).colorScheme;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Row(
                            children: [
                              Icon(Icons.logout, color: scheme.error),
                              const SizedBox(width: 8),
                              const Text('Logout'),
                            ],
                          ),
                          content: const Text('Are you sure you want to logout? You will be returned to the login screen.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm != true) return;
                    try {
                      await auth.signout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
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
