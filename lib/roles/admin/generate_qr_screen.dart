import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_project/services/user_service.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final _studentIdCtrl = TextEditingController();
  String? _currentCode;
  bool _loading = false;
  String? _status;

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter Student ID', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _studentIdCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 2023304637',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleGenerate,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Generate & Save Code'),
                  ),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Text(_status!, style: const TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 24),
                if (_currentCode != null) ...[
                  Center(
                    child: QrImageView(
                      data: _currentCode!,
                      version: QrVersions.auto,
                      size: 220,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText('Code: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(_currentCode!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _randomNumeric({int length = 6}) {
    final r = Random.secure();
    return List.generate(length, (_) => r.nextInt(10).toString()).join();
  }

  Future<void> _handleGenerate() async {
    final id = _studentIdCtrl.text.trim();
    if (id.isEmpty) {
      setState(() => _status = 'Please enter a student ID');
      return;
    }
    setState(() {
      _loading = true;
      _status = null;
    });

    try {
      final uid = await UserService().findUidByStudentId(id);
      final code = _randomNumeric(length: 6);
      if (uid != null) {
        await UserService().setPresentCode(uid: uid, code: code);
        setState(() {
          _currentCode = code;
          _status = 'Code saved to user document and QR generated.';
        });
      } else {
        // Fallback path: store by studentId so admins can still issue codes even if user doc is missing.
        await UserService().setPresentCodeForStudentId(studentId: id, code: code);
        setState(() {
          _currentCode = code;
          _status = 'No user doc found. Saved code under present_codes/$id and generated QR.';
        });
      }
    } on FirebaseException catch (e) {
      setState(() => _status = 'Firestore error: ${e.message}');
    } catch (e) {
      setState(() => _status = 'Unexpected error');
    } finally {
      setState(() => _loading = false);
    }
  }
}
