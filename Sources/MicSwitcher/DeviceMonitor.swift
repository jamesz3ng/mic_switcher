import Foundation
import CoreAudio

class DeviceMonitor {
    private let audioManager = AudioDeviceManager()
    private var listenerBlock: AudioObjectPropertyListenerBlock?
    private var isMonitoring = false

    func start() {
        guard !isMonitoring else { return }

        // List current devices
        listCurrentDevices()

        // Set up listener for default input device changes
        setupDefaultInputDeviceListener()

        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }

        // Remove listener
        if listenerBlock != nil {
            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            AudioObjectRemovePropertyListenerBlock(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                DispatchQueue.main,
                listenerBlock!
            )

            listenerBlock = nil
        }

        isMonitoring = false
        print("Device monitoring stopped")
    }

    func getCurrentInputDevice() -> AudioDeviceManager.AudioDevice? {
        return audioManager.getDefaultInputDevice()
    }

    func manualSwitchToBuiltIn() {
        switchToBuiltInMicrophone()
    }

    func checkAndSwitchIfNeeded() {
        guard let currentInputDevice = audioManager.getDefaultInputDevice() else {
            return
        }

        // If current input is Bluetooth, switch to built-in
        if currentInputDevice.isBluetoothInput {
            switchToBuiltInMicrophone()
        }
    }

    private func listCurrentDevices() {
        let devices = audioManager.getAllDevices()
        let inputDevices = devices.filter { $0.isInput }

        print("Available input devices:")
        for device in inputDevices {
            let type = getTransportTypeName(device.transportType)
            let isCurrent = (audioManager.getDefaultInputDevice()?.id == device.id) ? " [CURRENT]" : ""
            print("  - \(device.name) (\(type))\(isCurrent)")
        }
        print()

        if let builtIn = audioManager.findBuiltInMicrophone() {
            print("✓ Found built-in microphone: \(builtIn.name)")
        } else {
            print("⚠️  Warning: Could not find built-in microphone")
        }
        print()
    }

    private func getTransportTypeName(_ type: AudioDeviceManager.AudioDeviceTransportType) -> String {
        switch type {
        case .builtIn:
            return "Built-in"
        case .bluetooth:
            return "Bluetooth"
        case .usb:
            return "USB"
        case .other:
            return "Other"
        }
    }

    private func setupDefaultInputDeviceListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        // Create listener block
        listenerBlock = { [weak self] (numberAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>) -> Void in
            self?.handleInputDeviceChange()
        }

        // Add listener
        let status = AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            DispatchQueue.main,
            listenerBlock!
        )

        if status == kAudioHardwareNoError {
            print("✓ Monitoring for input device changes...\n")
        } else {
            print("❌ Failed to set up device change listener (error: \(status))\n")
        }
    }

    private func handleInputDeviceChange() {
        guard let currentInputDevice = audioManager.getDefaultInputDevice() else {
            print("⚠️  Could not determine current input device")
            return
        }

        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] Input device changed to: \(currentInputDevice.name)")

        // Check if it's a Bluetooth input device
        if currentInputDevice.isBluetoothInput {
            print("  → Detected Bluetooth input device, switching to built-in microphone...")
            switchToBuiltInMicrophone()
        }
    }

    private func switchToBuiltInMicrophone() {
        guard let builtInMic = audioManager.findBuiltInMicrophone() else {
            print("  ❌ Could not find built-in microphone!")
            return
        }

        let success = audioManager.setDefaultInputDevice(builtInMic.id)

        if success {
            print("  ✓ Successfully switched input to: \(builtInMic.name)")
        } else {
            print("  ❌ Failed to switch input device")
        }
    }
}
