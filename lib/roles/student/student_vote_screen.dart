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
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    final dept = (data['departmentId'] as String?) ?? '';
    return _UserInfo(uid: uid, departmentId: dept);
  }

  List<String> _eligibleOrgs(String dept) {
    // All students: USG + their department org
    return [
      'USG',
      if (dept == 'IT') 'SITE'
      else if (dept == 'BFPT') 'AFPROTECHS'
      else if (dept == 'BTLED') 'PAFE'
    ];
  }
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
          .where('orgId', whereIn: eligibleOrgs)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs.map((d) => d.data()).toList();

        // Filter: For USG Representatives, only show matching user department
        final filtered = docs.where((c) {
          final org = c['orgId'] as String?;
          final pos = c['positionName'] as String?;
          final deptId = c['departmentId'] as String?;
          if (org == 'USG' && pos == 'Representative') {
            return deptId == userDept;
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
                          (org == 'USG' && pos == 'Representative') ? (userDept + ' Representative') : pos,
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
