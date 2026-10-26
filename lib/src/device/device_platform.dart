import 'package:flutter_guard/src/device/device_method_channel.dart';
import 'package:flutter_guard/src/device/integrity_report.dart';

abstract class DevicePlatform {
  static DevicePlatform instance = DeviceMethodChannel();
  
  Future<IntegrityReport?> checkDeviceIntegrity();
}