# MicSwitcher 🎤

A macOS menu bar app that automatically switches your audio input to the built-in microphone when Bluetooth headphones connect, with intelligent screen detection.

## The Problem

When you connect Bluetooth headphones to macOS, the system automatically sets the headphones' built-in microphone as the default input device. However, Bluetooth microphones often have poor quality compared to your Mac's built-in microphone. This utility solves that by automatically switching back to your Mac's built-in microphone while keeping audio output on your headphones.

## Features

- 🎯 Automatically detects when Bluetooth headphones become the input device
- 🔄 Instantly switches input back to built-in microphone
- 📊 Monitors audio device changes in real-time
- 🖥️ Detects screen wake/sleep events for intelligent switching
- 🎚️ Menu bar controls for manual switching and toggling auto-switch
- 🚀 Runs silently in the menu bar
- 💻 Native Swift implementation using Core Audio and Cocoa APIs

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode or Swift command-line tools

## Installation

### Quick Install

```bash
# Build and install the app
make install
```

This will:
1. Build the application
2. Create a .app bundle
3. Install it to `/Applications/MicSwitcher.app`

### Manual Build Steps

If you prefer to build manually:

```bash
# Build the executable
swift build -c release

# Create the app bundle
make app

# The app bundle will be at: .build/release/MicSwitcher.app
```

### Step 2: Launch the App

```bash
# Open the app
open /Applications/MicSwitcher.app

# Or use Spotlight: Cmd+Space, type "MicSwitcher"
```

You should see a microphone icon appear in your menu bar!

### Step 3: Set Up Automatic Startup (Optional)

To have MicSwitcher start automatically when you log in:

```bash
# Copy the LaunchAgent plist
cp com.user.micswitcher.plist ~/Library/LaunchAgents/

# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.micswitcher.plist

# To unload (stop) the service:
# launchctl unload ~/Library/LaunchAgents/com.user.micswitcher.plist
```

Or simply add MicSwitcher to your Login Items in System Settings > General > Login Items.

## Usage

### Menu Bar Controls

Click the microphone icon in your menu bar to access:

- **Enable/Disable Auto-Switch** (⌘T): Toggle automatic switching on/off
- **Switch to Built-in Mic Now** (⌘S): Manually switch to built-in microphone
- **Current Device**: Shows your current input device
- **Quit** (⌘Q): Close the application

### Automatic Behavior

The app will:
- Monitor audio device changes in real-time
- Automatically switch to built-in mic when Bluetooth headphones become the input device
- Re-check and switch when your screen wakes up (in case devices changed while asleep)
- Continue running silently in the menu bar

### Screen Detection

MicSwitcher monitors screen wake/sleep events:
- When your screen wakes up, it checks if a Bluetooth device is the current input and switches if needed
- This ensures you always have the built-in mic active after waking from sleep

## How It Works

1. **Menu Bar App**: Runs as a native macOS menu bar application (LSUIElement)
2. **Device Monitoring**: Uses Core Audio APIs to monitor changes to the default input device
3. **Detection**: When a change is detected, it checks if the new input device is a Bluetooth device
4. **Switching**: If a Bluetooth input is detected, it immediately switches to the built-in microphone
5. **Screen Monitoring**: Uses NSWorkspace notifications to detect screen wake/sleep events
6. **Smart Recovery**: When screen wakes, re-checks and switches if needed
7. **Real-time**: All of this happens instantly and automatically

## Technical Details

- Written in Swift using Core Audio and Cocoa frameworks
- Uses `AudioObjectPropertyListenerBlock` for real-time device change notifications
- Uses `NSWorkspace.screensDidWakeNotification` and `NSWorkspace.screensDidSleepNotification` for screen state detection
- Queries device properties to identify transport types (Built-in, Bluetooth, USB, etc.)
- Minimal CPU usage - only responds to system events
- Menu bar only app (doesn't appear in Dock)

## Troubleshooting

### App Not Appearing in Menu Bar
Make sure the app is running:
```bash
# Check if it's running
ps aux | grep MicSwitcher

# Try launching it
open /Applications/MicSwitcher.app
```

### LaunchAgent Not Starting
Check if it's loaded:
```bash
launchctl list | grep micswitcher
```

If not loaded, load it:
```bash
launchctl load ~/Library/LaunchAgents/com.user.micswitcher.plist
```

### Not Detecting Bluetooth Devices
The app identifies devices by their transport type. You can check the current device from the menu bar. If your Bluetooth headphones aren't being detected as Bluetooth devices, please open an issue.

### Menu Bar Icon Not Showing
If the menu bar icon doesn't appear, make sure:
1. The app has the right permissions in System Settings > Privacy & Security
2. You're running macOS 11.0 or later
3. Try restarting the app

## Uninstalling

```bash
# Use the make uninstall command
make uninstall
```

Or manually:
```bash
# Stop and remove the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.micswitcher.plist 2>/dev/null
rm ~/Library/LaunchAgents/com.user.micswitcher.plist

# Remove the app
rm -rf /Applications/MicSwitcher.app
```

## Contributing

Feel free to open issues or submit pull requests!

## License

MIT License - feel free to use and modify as needed.

## Credits

Built with ♥️ using Swift and Core Audio APIs.
