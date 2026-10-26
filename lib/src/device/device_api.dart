import 'package:flutter_guard/src/device/device_platform.dart';
import 'package:flutter_guard/src/device/integrity_report.dart';

/// Device integrity checks. Access it through [FlutterGuard.device].
class DeviceApi {
  const DeviceApi();

  /// Runs all integrity checks on the current device.
  ///
  /// Throws a [FlutterGuardException] if the platform call fails.
  Future<IntegrityReport?> check() {
    return DevicePlatform.instance.checkDeviceIntegrity();
  }
}
