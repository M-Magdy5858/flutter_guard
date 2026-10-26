import 'package:flutter_secure_guard/src/device/device_api.dart';
import 'package:flutter_secure_guard/src/screen/screen_api.dart';

/// Entry point for the flutter_secure_guard plugin.
class FlutterGuard {
  /// Device integrity checks (root/jailbreak, emulator, debugger, hooks).
  static const device = DeviceApi();

  /// Screenshot and screen recording protection.
  static const screen = ScreenApi();
}
