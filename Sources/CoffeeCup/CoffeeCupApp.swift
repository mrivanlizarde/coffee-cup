import AppKit
import ServiceManagement

/// Coffee Cup: a menu bar toggle for `caffeinate -dims`.
///
/// One status item. Left-click toggles. Right-click (or Control/Option-click)
/// shows a two-item menu: Launch at Login, Quit. That is the whole app.
@main
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    private var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private let launchAtLoginItem = NSMenuItem(
        title: "Launch at Login",
        action: #selector(toggleLaunchAtLogin),
        keyEquivalent: ""
    )

    /// The running `caffeinate` process, or nil when the Mac is allowed to sleep.
    private var caffeinate: Process?

    private var isAwake: Bool { caffeinate?.isRunning == true }

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(statusItemClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        launchAtLoginItem.target = self
        menu.addItem(launchAtLoginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit Coffee Cup",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        menu.delegate = self

        render()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Belt: stop caffeinate on a clean quit.
        // Braces: caffeinate is started with `-w <our pid>`, so it also exits
        // on its own if this app is force-quit or crashes. No orphans either way.
        caffeinate?.terminate()
    }

    // MARK: - Click handling

    @objc private func statusItemClicked(_ sender: Any?) {
        let event = NSApp.currentEvent
        let wantsMenu = event?.type == .rightMouseUp
            || event?.modifierFlags.contains(.control) == true
            || event?.modifierFlags.contains(.option) == true
        if wantsMenu {
            showMenu()
        } else {
            toggle()
        }
    }

    private func showMenu() {
        launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        // Attach the menu only for the duration of this click, so a plain
        // left-click keeps toggling instead of opening the menu.
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }

    // MARK: - caffeinate

    private func toggle() {
        if isAwake { stop() } else { start() }
    }

    private func start() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        // Exactly what you would type in Terminal, plus `-w <pid>` so the
        // assertion is tied to this app's lifetime and can never outlive it.
        process.arguments = [
            "-dims",
            "-w", String(ProcessInfo.processInfo.processIdentifier),
        ]
        process.terminationHandler = { [weak self] finished in
            DispatchQueue.main.async {
                guard let self, self.caffeinate === finished else { return }
                self.caffeinate = nil
                self.render()
            }
        }
        do {
            try process.run()
            caffeinate = process
        } catch {
            caffeinate = nil
            NSLog("Coffee Cup: could not start caffeinate: \(error.localizedDescription)")
        }
        render()
    }

    private func stop() {
        let process = caffeinate
        caffeinate = nil
        process?.terminate()
        render()
    }

    // MARK: - Launch at Login

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Coffee Cup: launch at login failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Icon

    private func render() {
        guard let button = statusItem.button else { return }
        let symbolName = isAwake ? "cup.and.heat.waves.fill" : "cup.and.saucer"
        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
        image?.isTemplate = true
        button.image = image
        // Template images take the menu bar's foreground colour (white on dark,
        // black on light). appearsDisabled dims that to the system grey, which
        // is the "off" look in both appearances.
        button.appearsDisabled = !isAwake
        button.toolTip = isAwake
            ? "Coffee Cup is on. Your Mac will stay awake."
            : "Coffee Cup is off. Click to keep your Mac awake."
        button.setAccessibilityLabel(isAwake ? "Coffee Cup, on" : "Coffee Cup, off")
    }
}
