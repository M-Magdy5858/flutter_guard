import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_secure_guard/flutter_secure_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  IntegrityReport? _report;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    IntegrityReport? report;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      report = await FlutterGuard.device.check();
    } on PlatformException {
      //
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _report = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: _report == null
            ? const Center(child: CircularProgressIndicator())
            : ReportView(report: _report!),
      ),
    );
  }
}

class ScreenProtectionTile extends StatefulWidget {
  const ScreenProtectionTile({super.key});

  @override
  State<ScreenProtectionTile> createState() => _ScreenProtectionTileState();
}

class _ScreenProtectionTileState extends State<ScreenProtectionTile> {
  bool _enabled = false;
  bool _busy = false;

  Future<void> _toggle(bool value) async {
    setState(() => _busy = true);
    try {
      if (value) {
        await FlutterGuard.screen.enableProtection();
      } else {
        await FlutterGuard.screen.disableProtection();
      }
      _enabled = value;
    } on FlutterGuardException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(_enabled ? Icons.lock : Icons.lock_open),
      title: const Text('Screen protection'),
      subtitle: const Text('Blocks screenshots & screen recording'),
      value: _enabled,
      onChanged: _busy ? null : _toggle,
    );
  }
}

class ReportView extends StatelessWidget {
  const ReportView({super.key, required this.report});
  final IntegrityReport report;

  @override
  Widget build(BuildContext context) {
    final checks = {
      'Rooted / Jailbroken': report.isRooted,
      'Emulator': report.isEmulator,
      'Debug mode / debugger': report.isDebuggerAttached,
      'Hooking framework': report.isHooked,
    };
    final isCompromised = checks.values.any((v) => v);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ScreenProtectionTile(),
        const Divider(),
        Card(
          color: isCompromised ? Colors.red.shade50 : Colors.green.shade50,
          child: ListTile(
            leading: Icon(
              isCompromised ? Icons.gpp_bad : Icons.verified_user,
              color: isCompromised ? Colors.red : Colors.green,
              size: 36,
            ),
            title: Text(
              isCompromised ? 'Device compromised' : 'Device looks secure',
            ),
            subtitle: Text(
              '${checks.values.where((v) => v).length} of ${checks.length} checks flagged',
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...checks.entries.map(
          (e) => ListTile(
            leading: Icon(
              e.value ? Icons.warning_amber_rounded : Icons.check_circle,
              color: e.value ? Colors.orange : Colors.green,
            ),
            title: Text(e.key),
            trailing: Text(e.value ? 'DETECTED' : 'OK'),
          ),
        ),
        if (report.reasons.isNotEmpty) ...[
          const Divider(),
          Text('Reasons', style: Theme.of(context).textTheme.titleMedium),
          ...report.reasons.map(
            (r) => ListTile(
              dense: true,
              leading: const Icon(Icons.info_outline, size: 18),
              title: Text(r),
            ),
          ),
        ],
      ],
    );
  }
}
