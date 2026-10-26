# flutter_guard

Screen capture protection and device integrity checks for Flutter apps.

- **Screen protection**: block screenshots and screen recording of sensitive
  screens, and hide app content in the iOS app switcher.
- **Device integrity**: detect rooted/jailbroken devices, emulators and
  simulators, attached debuggers, and hooking frameworks such as Frida, Xposed
  and Substrate.

| Platform | Minimum version |
|----------|-----------------|
| Android  | API 24 (7.0)    |
| iOS      | 13.0            |

## Installation

```bash
flutter pub add flutter_guard
```

No extra Android or iOS setup is needed.

## Usage

```dart
import 'package:flutter_guard/flutter_guard.dart';
```

### Screen protection

```dart
// e.g. in initState of a payment or login screen
await FlutterGuard.screen.enableProtection();

// e.g. in dispose
await FlutterGuard.screen.disableProtection();
```

| | Android | iOS |
|---|---|---|
| Screenshots | Blocked (`FLAG_SECURE`) | Captured as blank |
| Screen recording | Blocked | Recorded as blank |
| App switcher preview | Hidden | Blurred |

### Device integrity

```dart
final report = await FlutterGuard.device.check();

if (report != null &&
    (report.isRooted || report.isHooked || report.isDebuggerAttached)) {
  // Restrict sensitive features, warn the user, log to your backend, ...
}

print(report?.reasons); // e.g. [su_binary, usb_debugging]
```

`IntegrityReport` fields:

| Field | Meaning |
|-------|---------|
| `isRooted` | Rooted (Android) or jailbroken (iOS) |
| `isEmulator` | Running on an emulator or simulator |
| `isDebuggerAttached` | A debugger is attached. On Android this also covers USB debugging and developer options being on |
| `isHooked` | A hooking framework (Frida, Xposed, Substrate, ...) was detected |
| `reasons` | A code for each check that was flagged |

Reason codes:

| Flag | Android | iOS |
|------|---------|-----|
| `isRooted` | `su_binary`, `test_keys` | `jailbreak_files`, `sandbox_escape` |
| `isEmulator` | `emulator_build` | `simulator` |
| `isDebuggerAttached` | `java_debugger`, `native_tracer`, `usb_debugging`, `developer_options` | `debugger_attached` |
| `isHooked` | `frida_loaded`, `xposed_loaded` | `dyld_insert`, `frida_loaded`, `substrate_loaded` |

> Running your app from your IDE in debug mode will usually flag
> `isDebuggerAttached` (and `isEmulator` on an emulator/simulator). Test
> integrity checks with a release build on a real device.

### Errors

Platform failures are thrown as `FlutterGuardException`:

```dart
try {
  await FlutterGuard.screen.enableProtection();
} on FlutterGuardException catch (e) {
  print('${e.code}: ${e.message}');
}
```

| Code | When |
|------|------|
| `NO_ACTIVITY` | Android: the plugin is not attached to an Activity |
| `NO_WINDOW` | iOS: no key window is available |

## Limitations

These checks run on the client and raise the bar for attackers, but a
determined attacker on a compromised device can bypass them. Don't rely on
them alone for security decisions. For server-side verification, pair this
plugin with [Play Integrity](https://developer.android.com/google/play/integrity)
or [App Attest](https://developer.apple.com/documentation/devicecheck).

## License

MIT. See [LICENSE](LICENSE).
