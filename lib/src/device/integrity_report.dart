/// Result of [DeviceApi.check].
class IntegrityReport {
  /// Whether the device is rooted (Android) or jailbroken (iOS).
  final bool isRooted;

  /// Whether the app is running on an emulator or simulator.
  final bool isEmulator;

  /// Whether a debugger is attached. On Android this is also true when USB
  /// debugging or developer options are enabled.
  final bool isDebuggerAttached;

  /// Whether a hooking framework such as Frida, Xposed or Substrate was found.
  final bool isHooked;

  /// A code for each check that was flagged, e.g. `su_binary`.
  final List<String> reasons;

  IntegrityReport({
    required this.isRooted,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.isHooked,
    required this.reasons,
  });

  /// Creates a report from the map sent by the platform side.
  factory IntegrityReport.fromMap(Map map) {
    return IntegrityReport(
      isRooted: map['isRooted'] as bool,
      isEmulator: map['isEmulator'] as bool,
      isDebuggerAttached: map['isDebuggerAttached'] as bool,
      isHooked: map['isHooked'] as bool,
      reasons: List<String>.from(map['reasons'] as List),
    );
  }
}