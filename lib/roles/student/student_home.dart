import 'package:flutter/material.dart';
import 'package:flutter_project/auth/auth_service.dart';
import 'package:flutter_project/auth/login_screen.dart';
import 'package:flutter_project/widgets/placeholder_page.dart';
import 'package:flutter_project/roles/student/student_vote_screen.dart';

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('ELECOM Student')),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/ELECOM.png', height: 56, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              const Text('ELECOM', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Student Dashboard', style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 24),
              _menuBtn(context, Icons.dashboard, 'Dashboard', () => _open(context, 'Dashboard')),
              const SizedBox(height: 12),
              _menuBtn(context, Icons.how_to_vote, 'Vote', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentVoteScreen()),
                );
              }),
              const SizedBox(height: 12),
              _menuBtn(context, Icons.task_alt, 'Confirm Vote', () => _open(context, 'Confirm Vote')),
              const SizedBox(height: 12),
              _menuBtn(context, Icons.receipt_long, 'Print Receipt', () => _open(context, 'Print Receipt')),
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

  Widget _menuBtn(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
      ),
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
