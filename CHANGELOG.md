## 0.1.0

* Initial release.
* `FlutterGuard.screen.enableProtection()` / `disableProtection()`: block
  screenshots and screen recording (Android `FLAG_SECURE`, iOS secure layer),
  and blur the iOS app switcher snapshot while protection is on.
* `FlutterGuard.device.check()`: returns an `IntegrityReport` flagging
  root/jailbreak, emulator/simulator, attached debuggers and hooking
  frameworks (Frida, Xposed, Substrate), with a reason code for each check.
