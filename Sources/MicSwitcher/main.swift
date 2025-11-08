import Cocoa

// Create the shared application instance
let app = NSApplication.shared

// Create and set the delegate
let delegate = AppDelegate()
app.delegate = delegate

// Activate the app and run
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
