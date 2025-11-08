import Foundation
import CoreAudio

print("🎤 MicSwitcher started - monitoring audio device changes...")
print("This utility will automatically switch input to built-in microphone when Bluetooth headphones connect.")
print("Press Ctrl+C to quit.\n")

let monitor = DeviceMonitor()
monitor.start()

// Keep the program running
RunLoop.main.run()
