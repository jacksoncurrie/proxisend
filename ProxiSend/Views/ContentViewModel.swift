//
//  ContentViewModel.swift
//  ProxiSend
//
//  Created by Jackson Currie on 28/04/2025.
//

import SwiftUI
import CoreBluetooth

class ContentViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    @Published var textInput: String = ""
    @Published var isEnabled = false
    @Published var devices: [CBPeripheral] = []
    @Published var loadingDevice: UUID? = nil
    @Published var showPopup: Bool = false
    @Published var popupText: String = ""
    @Published var historyItems = ["Test1", "Test2", "Test3"]
    
    private var centralManager: CBCentralManager!
    
    private var peripheralManager: CBPeripheralManager!
    private var isAdvertising = false

    private var writableCharacteristic: CBMutableCharacteristic?
    private var advertisementDataToAdvertise: [String: Any]?

    private var lastSeen: [UUID: Date] = [:]
    private var cleanupTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.removeStaleDevices()
        }
    }
    
    func tapDevice(_ device: CBPeripheral) {
        loadingDevice = device.identifier
        device.delegate = self
        centralManager.connect(device, options: nil)
        print("Connecting to \(device.name ?? "unknown device") to send text")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isEnabled = true
            centralManager.scanForPeripherals(
                withServices: [CBUUID(string: "12345678-1234-1234-1234-123456789ABC")],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            )
        case .unauthorized:
            print("Bluetooth permission not granted.")
            isEnabled = false

        case .poweredOff:
            print("Bluetooth is turned off.")
            isEnabled = false

        default:
            print("Bluetooth state: \(central.state.rawValue)")
            isEnabled = false
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        lastSeen[peripheral.identifier] = Date()
        if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
            devices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID(string: "12345678-1234-1234-1234-123456789ABC")])
        print("Discovering services on \(peripheral.name ?? "unknown device")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: "87654321-4321-4321-4321-CBA987654321")], for: service)
            print("Discovering characterisitics on \(service.uuid)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Found chacateristic \(characteristic.uuid)")
            if characteristic.uuid == CBUUID(string: "87654321-4321-4321-4321-CBA987654321") {
                if let data = textInput.data(using: .utf8) {
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    print("Writing value \(textInput) to characteristic")
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Write failed: \(error)")
        } else {
            print("Write succeeded for \(characteristic.uuid). Disconnecting.")
            centralManager.cancelPeripheralConnection(peripheral)
            loadingDevice = nil
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()
        } else {
            stopAdvertising()
        }
    }
    
    private func startAdvertising() {
        guard let peripheralManager = peripheralManager, !isAdvertising else { return }

        let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
        let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-CBA987654321")

        let writableCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.write],
            value: nil,
            permissions: [.writeable]
        )
        
        self.writableCharacteristic = writableCharacteristic

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [writableCharacteristic]

        peripheralManager.add(service)

        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: UIDevice.current.name,
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ]
        advertisementDataToAdvertise = advertisementData
    }

    private func stopAdvertising() {
        peripheralManager?.stopAdvertising()
        isAdvertising = false
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value, let stringValue = String(data: value, encoding: .utf8) {
                print("Received write: \(stringValue)")
                popupText = stringValue
                showPopup = true
                writableCharacteristic?.value = value
            }
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Failed to add service: \(error)")
        } else {
            print("Service successfully added")
            if let data = advertisementDataToAdvertise {
                peripheralManager.startAdvertising(data)
                isAdvertising = true
            }
        }
    }
    private func removeStaleDevices() {
        let now = Date()
        let timeout: TimeInterval = 5.0
        devices.removeAll { device in
            if let seen = lastSeen[device.identifier], now.timeIntervalSince(seen) < timeout {
                return false
            }
            return true
        }
    }
}
