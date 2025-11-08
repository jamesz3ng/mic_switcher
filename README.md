# MicSwitcher 🎤

A macOS utility that automatically switches your audio input to the built-in microphone when Bluetooth headphones connect.

## The Problem

When you connect Bluetooth headphones to macOS, the system automatically sets the headphones' built-in microphone as the default input device. However, Bluetooth microphones often have poor quality compared to your Mac's built-in microphone. This utility solves that by automatically switching back to your Mac's built-in microphone while keeping audio output on your headphones.

## Features

- 🎯 Automatically detects when Bluetooth headphones become the input device
- 🔄 Instantly switches input back to built-in microphone
- 📊 Monitors audio device changes in real-time
- 🚀 Runs silently in the background
- 💻 Native Swift implementation using Core Audio APIs

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode or Swift command-line tools

## Installation

### Step 1: Build the Utility

```bash
# Clone the repository (if you haven't already)
cd mic_switcher

# Build the project
swift build -c release

# The executable will be at: .build/release/mic-switcher
```

### Step 2: Install the Executable

```bash
# Create a bin directory in your home folder (if it doesn't exist)
mkdir -p ~/bin

# Copy the executable
cp .build/release/mic-switcher ~/bin/

# Make it executable
chmod +x ~/bin/mic-switcher
```

### Step 3: Test It Manually

```bash
# Run the utility
~/bin/mic-switcher
```

You should see output like:
```
🎤 MicSwitcher started - monitoring audio device changes...
Available input devices:
  - MacBook Pro Microphone (Built-in) [CURRENT]
  - AirPods Pro (Bluetooth)
✓ Found built-in microphone: MacBook Pro Microphone
✓ Monitoring for input device changes...
```

Try connecting your Bluetooth headphones, and you should see it automatically switch!

### Step 4: Set Up Automatic Startup (Optional)

To have MicSwitcher start automatically when you log in:

```bash
# Copy the LaunchAgent plist
cp com.user.micswitcher.plist ~/Library/LaunchAgents/

# Update the path in the plist to match your username
# Edit ~/Library/LaunchAgents/com.user.micswitcher.plist
# Replace /Users/YOUR_USERNAME with your actual home directory path

# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.user.micswitcher.plist

# To unload (stop) the service:
# launchctl unload ~/Library/LaunchAgents/com.user.micswitcher.plist
```

## Usage

### Running Manually

```bash
~/bin/mic-switcher
```

Press `Ctrl+C` to stop.

### Running as Background Service

Once you've set up the LaunchAgent (Step 4 above), the utility will:
- Start automatically when you log in
- Run in the background
- Log output to `~/Library/Logs/MicSwitcher.log`

### Checking Logs

```bash
tail -f ~/Library/Logs/MicSwitcher.log
```

## How It Works

1. **Monitoring**: The utility uses Core Audio APIs to monitor changes to the default input device
2. **Detection**: When a change is detected, it checks if the new input device is a Bluetooth device
3. **Switching**: If a Bluetooth input is detected, it immediately switches to the built-in microphone
4. **Real-time**: All of this happens instantly and automatically

## Technical Details

- Written in Swift using Core Audio framework
- Uses `AudioObjectPropertyListenerBlock` for real-time device change notifications
- Queries device properties to identify transport types (Built-in, Bluetooth, USB, etc.)
- Minimal CPU usage - only responds to system events

## Troubleshooting

### "Permission Denied" Error
Make sure the executable has the right permissions:
```bash
chmod +x ~/bin/mic-switcher
```

### LaunchAgent Not Starting
Check if it's loaded:
```bash
launchctl list | grep micswitcher
```

View logs:
```bash
cat ~/Library/Logs/MicSwitcher.log
```

### Not Detecting Bluetooth Devices
The utility identifies devices by their transport type. If your Bluetooth headphones aren't being detected, run the utility manually and check the device list it prints at startup.

## Uninstalling

```bash
# Stop and remove the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.micswitcher.plist
rm ~/Library/LaunchAgents/com.user.micswitcher.plist

# Remove the executable
rm ~/bin/mic-switcher

# Remove logs
rm ~/Library/Logs/MicSwitcher.log
```

## Contributing

Feel free to open issues or submit pull requests!

## License

MIT License - feel free to use and modify as needed.

## Credits

Built with ♥️ using Swift and Core Audio APIs.
