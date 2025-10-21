import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRegisterCandidateScreen extends StatefulWidget {
  const AdminRegisterCandidateScreen({super.key});

  @override
  State<AdminRegisterCandidateScreen> createState() => _AdminRegisterCandidateScreenState();
}

class _AdminRegisterCandidateScreenState extends State<AdminRegisterCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _yearSection = TextEditingController();
  final _platform = TextEditingController();
  final _photoUrl = TextEditingController();

  String? _department; // IT, BFPT, BTLED
  String? _org; // USG, SITE, PAFE, AFPROTECHS
  String? _position; // President...Representative

  bool _saving = false;

  final _orgs = const ['USG', 'SITE', 'PAFE', 'AFPROTECHS'];
  final _allPositions = const [
    'President',
    'Vice President',
    'General Secretary',
    'Associate Secretary',
    'Treasurer',
    'Auditor',
    'PIO',
    'Representative',
  ];
  final _departments = const ['IT', 'BFPT', 'BTLED'];

  @override
  void dispose() {
    _fullName.dispose();
    _yearSection.dispose();
    _platform.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  List<String> _positionsForOrg(String? org) {
    if (org == 'USG') return _allPositions;
    // Department orgs: no Representative race here
    return _allPositions.where((p) => p != 'Representative').toList(growable: false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_org == null || _position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select organization and position')),
      );
      return;
    }
    // If Representative in USG, require department selection (IT/BFPT/BTLED)
    if (_position == 'Representative' && _org == 'USG' && _department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Department is required for USG Representative candidates (IT/BFPT/BTLED)')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'fullName': _fullName.text.trim(),
        'yearSection': _yearSection.text.trim(),
        'platform': _platform.text.trim(),
        'photoUrl': _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
        'orgId': _org,
        'positionName': _position,
        'departmentId': (_position == 'Representative' && _org == 'USG') ? _department : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('candidates').add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidate registered')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Candidate')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full name', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _fullName,
                    decoration: const InputDecoration(hintText: 'Enter full name', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  const Text('Year & Section', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _yearSection,
                    decoration: const InputDecoration(hintText: 'e.g., BSIT-3A', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  const Text('Organization', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _org,
                    items: _orgs.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                    onChanged: (v) => setState(() {
                      _org = v;
                      // If org is not USG, ensure position isn't Representative
                      if (_org != 'USG' && _position == 'Representative') {
                        _position = null;
                      }
                    }),
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select organization'),
                    validator: (v) => v == null ? 'Select organization' : null,
                  ),
                  const SizedBox(height: 12),

                  const Text('Position', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _position,
                    items: _positionsForOrg(_org).map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => _position = v),
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select position'),
                    validator: (v) => v == null ? 'Select position' : null,
                  ),
                  const SizedBox(height: 12),

                  if (_position == 'Representative' && _org == 'USG') ...[
                    const Text('USG Representative Type (IT/BFPT/BTLED)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _department,
                      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _department = v),
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select representative type'),
                      validator: (v) => (_position == 'Representative' && _org == 'USG' && v == null) ? 'Select representative type' : null,
                    ),
                    const SizedBox(height: 12),
                  ],

                  const Text('Platform', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _platform,
                    decoration: const InputDecoration(hintText: 'Enter platform/advocacy', border: OutlineInputBorder()),
                    maxLines: 4,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  const Text('Profile picture URL (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _photoUrl,
                    decoration: const InputDecoration(hintText: 'https://...', border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Candidate'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
