import AppKit

final class RCXrayAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var permissionMenuItems: [PermissionKind: NSMenuItem] = [:]

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "scope", accessibilityDescription: "RC-X-ray")
        statusItem.button?.toolTip = "RC-X-ray"

        let menu = NSMenu()
        menu.addItem(withTitle: "RC-X-ray", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "Refresh Permission Status", action: #selector(refreshPermissionStatus), keyEquivalent: "r")
        for kind in [PermissionKind.screenRecording, .accessibility] {
            let item = NSMenuItem(title: "", action: #selector(openPermissionSettings(_:)), keyEquivalent: "")
            item.representedObject = kind
            menu.addItem(item)
            permissionMenuItems[kind] = item
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit RC-X-ray", action: #selector(quit), keyEquivalent: "q")
        statusItem.menu = menu
        refreshPermissionStatus()
    }

    @objc private func refreshPermissionStatus() {
        let snapshot = Permissions.snapshot()
        permissionMenuItems[.screenRecording]?.title = permissionTitle(.screenRecording, granted: snapshot.screenRecording)
        permissionMenuItems[.accessibility]?.title = permissionTitle(.accessibility, granted: snapshot.accessibility)
    }

    @objc private func openPermissionSettings(_ sender: NSMenuItem) {
        guard let kind = sender.representedObject as? PermissionKind else { return }
        Permissions.openSettings(for: kind)
    }

    private func permissionTitle(_ kind: PermissionKind, granted: Bool) -> String {
        "\(granted ? "✓" : "⚠︎") (kind.label): \(granted ? "Granted" : "Open System Settings")"
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

@main
enum RCXrayMain {
    static func main() {
        let application = NSApplication.shared
        let delegate = RCXrayAppDelegate()
        application.delegate = delegate
        application.run()
    }
}
