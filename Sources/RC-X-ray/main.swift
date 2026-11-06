import AppKit

final class RCXrayAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "scope", accessibilityDescription: "RC-X-ray")
        statusItem.button?.toolTip = "RC-X-ray"

        let menu = NSMenu()
        menu.addItem(withTitle: "RC-X-ray is ready", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit RC-X-ray", action: #selector(quit), keyEquivalent: "q")
        statusItem.menu = menu
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
