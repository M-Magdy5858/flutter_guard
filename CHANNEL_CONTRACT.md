# flutter_guard — Platform Channel Contract

Every message between Dart and native. Dart, Android and iOS must all match this file.

Codec: `StandardMethodCodec` (default). Map keys are `camelCase`.

| Channel                       | Type          | Dart owner                                |
|-------------------------------|---------------|-------------------------------------------|
| `flutter_guard/screen`        | MethodChannel | `lib/src/screen/screen_method_channel.dart` |
| `flutter_guard/screen_events` | EventChannel  | `lib/src/screen/screen_method_channel.dart` (planned) |
| `flutter_guard/integrity`     | MethodChannel | `lib/src/device/device_method_channel.dart` |

Native handlers:

| Channel                   | Android               | iOS                    |
|---------------------------|-----------------------|------------------------|
| `flutter_guard/screen`    | `ScreenGuard.kt`      | `ScreenHandler.swift`  |
| `flutter_guard/integrity` | `DeviceIntegrity.kt`  | `DeviceHandler.swift`  |

---

## `flutter_guard/screen`

| Method                  | Args | Returns | Android | iOS |
|-------------------------|------|---------|---------|-----|
| `enableProtection`      | none | `null`  | add `FLAG_SECURE` | secure `UITextField` layer (`isSecureTextEntry = true`) + blur on background |
| `disableProtection`     | none | `null`  | clear `FLAG_SECURE` | `isSecureTextEntry = false`, no blur (layer stays attached) |
| `isScreenBeingCaptured` | none | `bool`  | always `false` | `UIScreen.main.isCaptured` |

## `flutter_guard/screen_events`

Each event is a `Map`: `{ "type": "screenshotTaken" }`

| `type`             | Android | iOS |
|--------------------|---------|-----|
| `screenshotTaken`  | `ScreenCaptureCallback` (API 34+) | `userDidTakeScreenshotNotification` |
| `recordingStarted` | —       | `capturedDidChangeNotification`, `isCaptured == true` |
| `recordingStopped` | —       | `capturedDidChangeNotification`, `isCaptured == false` |

## `flutter_guard/integrity`

### `checkIntegrity`
Args: none. Returns a `Map`:

| Key                  | Type           | Meaning |
|----------------------|----------------|---------|
| `isRooted`           | `bool`         | Rooted (Android) / jailbroken (iOS) |
| `isEmulator`         | `bool`         | Emulator or simulator |
| `isDebuggerAttached` | `bool`         | Debugger connected (Android also: USB debugging / developer options on) |
| `isHooked`           | `bool`         | Frida / Xposed / Substrate detected |
| `reasons`            | `List<String>` | Codes for each failed check, see below |

```json
{
  "isRooted": true,
  "isEmulator": false,
  "isDebuggerAttached": false,
  "isHooked": false,
  "reasons": ["su_binary"]
}
```

#### Reason codes

| Flag                 | Android | iOS |
|----------------------|---------|-----|
| `isRooted`           | `su_binary`, `test_keys` | `jailbreak_files`, `sandbox_escape` |
| `isEmulator`         | `emulator_build` | `simulator` |
| `isDebuggerAttached` | `java_debugger`, `native_tracer`, `usb_debugging`, `developer_options` | `debugger_attached` |
| `isHooked`           | `frida_loaded`, `xposed_loaded` | `dyld_insert`, `frida_loaded`, `substrate_loaded` |

---

## Errors

| Code           | When |
|----------------|------|
| `NO_ACTIVITY`  | Android, `flutter_guard/screen`: plugin not attached to an Activity |
| `NO_WINDOW`    | iOS, `flutter_guard/screen`: no key window available |
| `CHECK_FAILED` | Reserved, not emitted yet. Failing checks currently count as "not detected" |

Unknown methods return `notImplemented()` / `FlutterMethodNotImplemented`.
