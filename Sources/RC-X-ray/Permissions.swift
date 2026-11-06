import ApplicationServices
import CoreGraphics
import Foundation
import AppKit

struct PermissionSnapshot {
    let screenRecording: Bool
    let accessibility: Bool

    var isReady: Bool { screenRecording && accessibility }
}

enum PermissionKind: Hashable {
    case screenRecording
    case accessibility

    var label: String {
        switch self {
        case .screenRecording: return "Screen Recording"
        case .accessibility: return "Accessibility / Input Monitoring"
        }
    }

    var settingsURL: URL? {
        let anchor: String
        switch self {
        case .screenRecording: anchor = "Privacy_ScreenCapture"
        case .accessibility: anchor = "Privacy_Accessibility"
        }
        return URL(string: "x-apple.systempreferences:com.apple.preference.security?\(anchor)")
    }
}

enum Permissions {
    static func snapshot() -> PermissionSnapshot {
        PermissionSnapshot(
            screenRecording: CGPreflightScreenCaptureAccess(),
            accessibility: AXIsProcessTrusted()
        )
    }

    static func openSettings(for kind: PermissionKind) {
        guard let url = kind.settingsURL else { return }
        NSWorkspace.shared.open(url)
    }
}
