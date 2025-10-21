import 'package:flutter/material.dart';
import 'package:flutter_project/roles/student/student_home.dart';
import 'package:flutter_project/widgets/placeholder_page.dart';
import 'package:flutter_project/auth/auth_service.dart';
import 'package:flutter_project/auth/login_screen.dart';

class StudentLanding extends StatelessWidget {
  const StudentLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_OrgItem>[
      _OrgItem('USG', 'USG.png', () => _open(context, 'USG')),
      _OrgItem('ARCU', 'ARCU.png', () => _open(context, 'ARCU')),
      _OrgItem('ELECOM', 'ELECOM.png', () => _openElecom(context)),
      _OrgItem('SITE', 'SITE.png', () => _open(context, 'SITE')),
      _OrgItem('PAFE', 'PAFE.png', () => _open(context, 'PAFE')),
      _OrgItem('AFPROTECHS', 'AFPROTECH.png', () => _open(context, 'AFPROTECHS')),
      _OrgItem('ACCESS', 'ACCESS.png', () => _open(context, 'ACCESS')),
      _OrgItem('REDCOSS', 'REDCROSS.png', () => _open(context, 'REDCOSS')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SocieTree'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await AuthService().signout();
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
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'About',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SocieTree centralizes campus organizations. Browse groups and open their pages. Tap ELECOM to access the student voting dashboard.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Organizations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _OrgCard(item: items[index]),
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceholderPage(title: title, description: '$title page placeholder'),
      ),
    );
  }

  static void _openElecom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentHome()),
    );
  }
}

class _OrgItem {
  final String label;
  final String assetFileName; 
  final VoidCallback onTap;
  _OrgItem(this.label, this.assetFileName, this.onTap);
}

class _OrgCard extends StatelessWidget {
  final _OrgItem item;
  const _OrgCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/' + item.assetFileName,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
