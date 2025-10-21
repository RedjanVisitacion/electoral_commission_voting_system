import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentVoteScreen extends StatelessWidget {
  const StudentVoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vote')),
      body: FutureBuilder<_UserInfo>(
        future: _loadUserInfo(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final user = snap.data!;
          final eligibleOrgs = _eligibleOrgs(user.departmentId);
          return _CandidatesList(userDept: user.departmentId, eligibleOrgs: eligibleOrgs);
        },
      ),
    );
  }

  Future<_UserInfo> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String dept = '';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      // Try multiple possible keys for department
      final candidates = [
        data['departmentId'],
        data['department'],
        data['dept'],
        data['Department'],
      ];
      for (final v in candidates) {
        if (v is String && v.trim().isNotEmpty) {
          dept = v.trim();
          break;
        }
      }
    } catch (_) {
      // Permission denied or offline: proceed without department
      dept = '';
    }
    return _UserInfo(uid: uid, departmentId: dept);
  }

  List<String> _eligibleOrgs(String dept) {
    // All students: USG + their department org (dept-insensitive)
    final d = _norm(dept);
    final list = <String>['USG'];
    if (d.isEmpty) {
      // Unknown department: show only USG
    } else if (d == 'IT') list.add('SITE');
    else if (d == 'BFPT') list.add('AFPROTECHS');
    else if (d == 'BTLED') list.add('PAFE');
    return list;
  }

  String _norm(String s) => s.trim().toUpperCase().replaceAll(' ', '');
}

class _CandidatesList extends StatelessWidget {
  final String userDept;
  final List<String> eligibleOrgs;
  const _CandidatesList({required this.userDept, required this.eligibleOrgs});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('candidates')
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Unable to load candidates. Please try again later.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs.map((d) => d.data()).toList();

        // Filter: For USG Representatives, only show matching user department
        final dNorm = userDept.trim().isEmpty ? '' : userDept.trim().toUpperCase().replaceAll(' ', '');
        final eligibleSet = eligibleOrgs.map((e) => e.trim().toUpperCase().replaceAll(' ', '')).toSet();
        final filtered = docs.where((c) {
          final org = c['orgId'] as String?;
          final pos = c['positionName'] as String?;
          final deptId = c['departmentId'] as String?;
          final orgNorm = (org ?? '').trim().toUpperCase().replaceAll(' ', '');
          if (!eligibleSet.contains(orgNorm)) return false;
          if (org == 'USG' && pos == 'Representative') {
            // If user's department is unknown, don't filter out reps so students can still view
            if (dNorm.isEmpty) return true;
            final cNorm = (deptId ?? '').toString().trim().toUpperCase().replaceAll(' ', '');
            return cNorm == dNorm;
          }
          // For other positions/orgs, show as-is
          return true;
        }).toList();

        // Group by org -> position
        final Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};
        for (final c in filtered) {
          final org = (c['orgId'] as String?) ?? 'Unknown';
          final pos = (c['positionName'] as String?) ?? 'Unknown';
          grouped.putIfAbsent(org, () => {});
          grouped[org]!.putIfAbsent(pos, () => []);
          grouped[org]![pos]!.add(c);
        }

        if (grouped.isEmpty) {
          return const Center(child: Text('No candidates available.'));
        }

        final scheme = Theme.of(context).colorScheme;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final org in ['USG', ...eligibleOrgs.where((o) => o != 'USG')])
              if (grouped.containsKey(org)) ...[
                Text(org, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final pos in _orderedPositions(grouped[org]!.keys.toList())) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: scheme.surface,
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (org == 'USG' && pos == 'Representative') ? ((userDept.isEmpty ? '' : userDept + ' ') + 'Representative') : pos,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...grouped[org]![pos]!.map((c) => _CandidateTile(data: c)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
          ],
        );
      },
    );
  }

  List<String> _orderedPositions(List<String> positions) {
    const order = [
      'President',
      'Vice President',
      'General Secretary',
      'Associate Secretary',
      'Treasurer',
      'Auditor',
      'PIO',
      'Representative',
    ];
    positions.sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));
    return positions;
  }
}

class _CandidateTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CandidateTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['fullName'] as String? ?? 'Candidate';
    final ys = data['yearSection'] as String? ?? '';
    final platform = data['platform'] as String? ?? '';
    final photoUrl = data['photoUrl'] as String?;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(name),
      subtitle: Text(ys.isEmpty ? platform : '$ys • $platform'),
    );
  }
}

class _UserInfo {
  final String uid;
  final String departmentId;
  _UserInfo({required this.uid, required this.departmentId});
}
