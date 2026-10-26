import 'package:flutter/services.dart';
import 'package:flutter_secure_guard/src/errors.dart';
import 'package:flutter_secure_guard/src/screen/screen_platform.dart';

class ScreenMethodChannel extends ScreenPlatform {
  final _channel = const MethodChannel("flutter_guard/screen");

  @override
  Future<Null> enableProtection() async {
    try {
      await _channel.invokeMapMethod("enableProtection");
    } on PlatformException catch (e) {
      throw FlutterGuardException.fromPlatform(e);
    }
  }
  @override
  Future<Null> disableProtection() async {
    try {
      await _channel.invokeMapMethod("disableProtection");
    } on PlatformException catch (e) {
      throw FlutterGuardException.fromPlatform(e);
    }
  }
}
