import Foundation
import CoreAudio

class AudioDeviceManager {

    // MARK: - Device Information

    struct AudioDevice {
        let id: AudioDeviceID
        let name: String
        let isInput: Bool
        let isOutput: Bool
        let transportType: AudioDeviceTransportType

        var isBluetoothInput: Bool {
            return isInput && transportType == .bluetooth
        }

        var isBuiltInInput: Bool {
            return isInput && transportType == .builtIn
        }
    }

    enum AudioDeviceTransportType {
        case builtIn
        case bluetooth
        case usb
        case other

        init(from fourCC: UInt32) {
            switch fourCC {
            case kAudioDeviceTransportTypeBuiltIn:
                self = .builtIn
            case kAudioDeviceTransportTypeBluetooth:
                self = .bluetooth
            case kAudioDeviceTransportTypeUSB:
                self = .usb
            default:
                self = .other
            }
        }
    }

    // MARK: - Get Devices

    func getAllDevices() -> [AudioDevice] {
        var devices: [AudioDevice] = []

        guard let deviceIDs = getAllDeviceIDs() else {
            return devices
        }

        for deviceID in deviceIDs {
            if let device = getDevice(deviceID) {
                devices.append(device)
            }
        }

        return devices
    }

    private func getAllDeviceIDs() -> [AudioDeviceID]? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        guard status == kAudioHardwareNoError else {
            return nil
        }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceIDs
        )

        guard status == kAudioHardwareNoError else {
            return nil
        }

        return deviceIDs
    }

    private func getDevice(_ deviceID: AudioDeviceID) -> AudioDevice? {
        guard let name = getDeviceName(deviceID),
              let transportType = getTransportType(deviceID) else {
            return nil
        }

        let isInput = hasInputStreams(deviceID)
        let isOutput = hasOutputStreams(deviceID)

        return AudioDevice(
            id: deviceID,
            name: name,
            isInput: isInput,
            isOutput: isOutput,
            transportType: transportType
        )
    }

    private func getDeviceName(_ deviceID: AudioDeviceID) -> String? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceName: CFString = "" as CFString
        var dataSize = UInt32(MemoryLayout<CFString>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceName
        )

        guard status == kAudioHardwareNoError else {
            return nil
        }

        return deviceName as String
    }

    private func getTransportType(_ deviceID: AudioDeviceID) -> AudioDeviceTransportType? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var transportType: UInt32 = 0
        var dataSize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &transportType
        )

        guard status == kAudioHardwareNoError else {
            return nil
        }

        return AudioDeviceTransportType(from: transportType)
    }

    private func hasInputStreams(_ deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        return status == kAudioHardwareNoError && dataSize > 0
    }

    private func hasOutputStreams(_ deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &dataSize
        )

        return status == kAudioHardwareNoError && dataSize > 0
    }

    // MARK: - Default Device Management

    func getDefaultInputDevice() -> AudioDevice? {
        guard let deviceID = getDefaultInputDeviceID() else {
            return nil
        }
        return getDevice(deviceID)
    }

    private func getDefaultInputDeviceID() -> AudioDeviceID? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioDeviceID = 0
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &dataSize,
            &deviceID
        )

        guard status == kAudioHardwareNoError else {
            return nil
        }

        return deviceID
    }

    func setDefaultInputDevice(_ deviceID: AudioDeviceID) -> Bool {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var mutableDeviceID = deviceID
        let dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            dataSize,
            &mutableDeviceID
        )

        return status == kAudioHardwareNoError
    }

    // MARK: - Find Specific Devices

    func findBuiltInMicrophone() -> AudioDevice? {
        let devices = getAllDevices()
        return devices.first { $0.isBuiltInInput }
    }
}
