import Flutter
import Foundation
import MachO

class DeviceHandler {
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "checkIntegrity" else {
            return result(FlutterMethodNotImplemented)
        }

        var reasons: [String] = []

        // Jailbreak
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/sbin/sshd",
            "/bin/bash",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/var/jb", // rootless jailbreaks (Dopamine, palera1n)
        ]
        if jailbreakPaths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            reasons.append("jailbreak_files")
        }
        if canWriteOutsideSandbox() { reasons.append("sandbox_escape") }

        // Emulator
        #if targetEnvironment(simulator)
        reasons.append("simulator")
        #endif

        // Debugger
        if isDebuggerAttached() { reasons.append("debugger_attached") }

        // Hooks
        if ProcessInfo.processInfo.environment["DYLD_INSERT_LIBRARIES"] != nil {
            reasons.append("dyld_insert")
        }
        let images = loadedImageNames()
        if images.contains(where: { $0.contains("frida") }) { reasons.append("frida_loaded") }
        if images.contains(where: { name in
            ["substrate", "substitute", "libhooker", "ellekit", "cycript"].contains { name.contains($0) }
        }) { reasons.append("substrate_loaded") }

        result([
            "isRooted": reasons.contains("jailbreak_files") || reasons.contains("sandbox_escape"),
            "isEmulator": reasons.contains("simulator"),
            "isDebuggerAttached": reasons.contains("debugger_attached"),
            "isHooked": ["dyld_insert", "frida_loaded", "substrate_loaded"].contains { reasons.contains($0) },
            "reasons": reasons,
        ])
    }

    private func canWriteOutsideSandbox() -> Bool {
        let path = "/private/flutter_guard_\(UUID().uuidString)"
        do {
            try "x".write(toFile: path, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    private func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        guard sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    private func loadedImageNames() -> [String] {
        (0..<_dyld_image_count()).compactMap { i in
            _dyld_get_image_name(i).map { String(cString: $0).lowercased() }
        }
    }
}
