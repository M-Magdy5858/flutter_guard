import 'package:flutter/services.dart';
import 'package:flutter_guard/flutter_guard.dart';
import 'package:flutter_guard/src/device/device_platform.dart';

class DeviceMethodChannel extends DevicePlatform {
  final _channel = const MethodChannel('flutter_guard/integrity');

  @override
  Future<IntegrityReport?> checkDeviceIntegrity() async {
    try {
      final rawRes = await _channel.invokeMethod<Map>(
        'checkIntegrity',
      );
      return IntegrityReport.fromMap(rawRes!);
    } on PlatformException catch (e) {
      throw FlutterGuardException.fromPlatform(e);
    }
  }
}
