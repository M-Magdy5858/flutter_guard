import Flutter
import UIKit

public class FlutterGuardPlugin: NSObject, FlutterPlugin {
  private static let deviceHandler = DeviceHandler()
  private static let screenHandler: ScreenHandler = ScreenHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let deviceChannel = FlutterMethodChannel(name: "flutter_guard/integrity", binaryMessenger: registrar.messenger())
    deviceChannel.setMethodCallHandler(deviceHandler.handle)

    let screenChannel = FlutterMethodChannel(name: "flutter_guard/screen", binaryMessenger: registrar.messenger())
    screenChannel.setMethodCallHandler(screenHandler.handle)
  }
}
