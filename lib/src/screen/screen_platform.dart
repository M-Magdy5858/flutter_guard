import 'package:flutter_secure_guard/src/screen/screen_method_channel.dart';

abstract class ScreenPlatform {
  static ScreenPlatform instance = ScreenMethodChannel();

  Future<Null> enableProtection();
  Future<Null> disableProtection();

}