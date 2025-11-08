import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Hide from dock and make it a menu bar only app
app.setActivationPolicy(.accessory)

app.run()
