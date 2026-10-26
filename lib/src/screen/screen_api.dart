import 'package:flutter_guard/src/screen/screen_platform.dart';

/// Screen capture protection. Access it through [FlutterGuard.screen].
class ScreenApi {
  const ScreenApi();

  /// Blocks screenshots and screen recording of the app's content.
  ///
  /// On Android this sets `FLAG_SECURE` on the activity window. On iOS the
  /// content is rendered blank in captures and blurred in the app switcher.
  ///
  /// Throws a [FlutterGuardException] with code `NO_ACTIVITY` (Android) or
  /// `NO_WINDOW` (iOS) if there is no screen to protect yet.
  Future<Null> enableProtection(){
    return ScreenPlatform.instance.enableProtection();
  }

  /// Turns off the protection enabled by [enableProtection].
  Future<Null> disableProtection(){
    return ScreenPlatform.instance.disableProtection();
  }
}
