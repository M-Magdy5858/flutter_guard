import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_guard/flutter_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const integrityChannel = MethodChannel('flutter_guard/integrity');
  const screenChannel = MethodChannel('flutter_guard/screen');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(integrityChannel, null);
    messenger.setMockMethodCallHandler(screenChannel, null);
  });

  test('device.check parses the integrity report', () async {
    messenger.setMockMethodCallHandler(integrityChannel, (call) async {
      expect(call.method, 'checkIntegrity');
      return {
        'isRooted': true,
        'isEmulator': false,
        'isDebuggerAttached': false,
        'isHooked': false,
        'reasons': ['su_binary'],
      };
    });

    final report = await FlutterGuard.device.check();

    expect(report!.isRooted, isTrue);
    expect(report.isEmulator, isFalse);
    expect(report.isDebuggerAttached, isFalse);
    expect(report.isHooked, isFalse);
    expect(report.reasons, ['su_binary']);
  });

  test('screen protection calls the native methods', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(screenChannel, (call) async {
      calls.add(call.method);
      return null;
    });

    await FlutterGuard.screen.enableProtection();
    await FlutterGuard.screen.disableProtection();

    expect(calls, ['enableProtection', 'disableProtection']);
  });

  test('platform errors become FlutterGuardException', () async {
    messenger.setMockMethodCallHandler(screenChannel, (call) async {
      throw PlatformException(code: 'NO_WINDOW', message: 'no window');
    });

    expect(
      FlutterGuard.screen.enableProtection(),
      throwsA(isA<FlutterGuardException>()
          .having((e) => e.code, 'code', 'NO_WINDOW')),
    );
  });
}
