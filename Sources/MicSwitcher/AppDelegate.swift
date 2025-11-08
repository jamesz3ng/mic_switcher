import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var deviceMonitor: DeviceMonitor!
    private var screenStateMonitor: ScreenStateMonitor!
    private var isEnabled: Bool = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "MicSwitcher")
            button.image?.isTemplate = true
        }

        // Create menu
        setupMenu()

        // Initialize monitors
        deviceMonitor = DeviceMonitor()
        screenStateMonitor = ScreenStateMonitor()

        // Set up screen state callbacks
        screenStateMonitor.onScreenWake = { [weak self] in
            self?.handleScreenWake()
        }

        screenStateMonitor.onScreenSleep = { [weak self] in
            self?.handleScreenSleep()
        }

        // Start monitoring
        screenStateMonitor.start()

        // Start device monitoring if enabled
        if isEnabled {
            deviceMonitor.start()
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Status item
        let statusMenuItem = NSMenuItem(title: "MicSwitcher", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Enable/Disable toggle
        let toggleMenuItem = NSMenuItem(
            title: isEnabled ? "Disable Auto-Switch" : "Enable Auto-Switch",
            action: #selector(toggleAutoSwitch),
            keyEquivalent: "t"
        )
        toggleMenuItem.tag = 1 // Tag to identify for updates
        menu.addItem(toggleMenuItem)

        // Manual switch option
        let switchNowMenuItem = NSMenuItem(
            title: "Switch to Built-in Mic Now",
            action: #selector(switchToBuiltInNow),
            keyEquivalent: "s"
        )
        menu.addItem(switchNowMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Show current device
        let currentDeviceMenuItem = NSMenuItem(title: "Current: ...", action: nil, keyEquivalent: "")
        currentDeviceMenuItem.tag = 2 // Tag to identify for updates
        currentDeviceMenuItem.isEnabled = false
        menu.addItem(currentDeviceMenuItem)

        menu.addItem(NSMenuItem.separator())

        // Quit option
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu

        // Update current device display
        updateCurrentDeviceDisplay()
    }

    @objc private func toggleAutoSwitch() {
        isEnabled.toggle()

        if isEnabled {
            deviceMonitor.start()
            print("Auto-switch enabled")
        } else {
            deviceMonitor.stop()
            print("Auto-switch disabled")
        }

        // Update menu item text
        if let menu = statusItem.menu,
           let toggleItem = menu.items.first(where: { $0.tag == 1 }) {
            toggleItem.title = isEnabled ? "Disable Auto-Switch" : "Enable Auto-Switch"
        }

        // Update status bar icon appearance
        updateStatusBarIcon()
    }

    @objc private func switchToBuiltInNow() {
        deviceMonitor.manualSwitchToBuiltIn()
        updateCurrentDeviceDisplay()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    private func handleScreenWake() {
        print("Screen woke up")
        if isEnabled {
            // Re-check and switch if needed
            deviceMonitor.checkAndSwitchIfNeeded()
        }
    }

    private func handleScreenSleep() {
        print("Screen going to sleep")
        // Could add logic here if needed
    }

    private func updateCurrentDeviceDisplay() {
        if let menu = statusItem.menu,
           let currentDeviceItem = menu.items.first(where: { $0.tag == 2 }) {
            if let currentDevice = deviceMonitor.getCurrentInputDevice() {
                currentDeviceItem.title = "Current: \(currentDevice.name)"
            } else {
                currentDeviceItem.title = "Current: Unknown"
            }
        }
    }

    private func updateStatusBarIcon() {
        if let button = statusItem.button {
            button.appearsDisabled = !isEnabled
        }
    }
}
