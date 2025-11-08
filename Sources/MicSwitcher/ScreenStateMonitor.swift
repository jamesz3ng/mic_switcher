import Foundation
import Cocoa

class ScreenStateMonitor {
    var onScreenWake: (() -> Void)?
    var onScreenSleep: (() -> Void)?

    private var workspaceNotificationObservers: [NSObjectProtocol] = []

    func start() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        // Monitor screen wake (screens did wake)
        let wakeObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onScreenWake?()
        }
        workspaceNotificationObservers.append(wakeObserver)

        // Monitor screen sleep (screens did sleep)
        let sleepObserver = notificationCenter.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onScreenSleep?()
        }
        workspaceNotificationObservers.append(sleepObserver)

        print("Screen state monitoring started")
    }

    func stop() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        for observer in workspaceNotificationObservers {
            notificationCenter.removeObserver(observer)
        }
        workspaceNotificationObservers.removeAll()
        print("Screen state monitoring stopped")
    }

    deinit {
        stop()
    }
}
