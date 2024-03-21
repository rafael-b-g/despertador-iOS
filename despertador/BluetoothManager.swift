//
//  BluetoothManager.swift
//  despertador
//
//  Created by Rafael Guimarães on 21/03/24.
//

import Foundation
import CoreBluetooth

@Observable class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static private let SimulationServiceUUID = CBUUID(string: "00000000-3141-5926-5358-979323846264")
    static private let SundaySimulationCharUUID = CBUUID(string: "00000001-3141-5926-5358-979323846264")
    static private let MondaySimulationCharUUID = CBUUID(string: "00000002-3141-5926-5358-979323846264")
    static private let TuesdaySimulationCharUUID = CBUUID(string: "00000003-3141-5926-5358-979323846264")
    static private let WednesdaySimulationCharUUID = CBUUID(string: "00000004-3141-5926-5358-979323846264")
    static private let ThursdaySimulationCharUUID = CBUUID(string: "00000005-3141-5926-5358-979323846264")
    static private let FridaySimulationCharUUID = CBUUID(string: "00000006-3141-5926-5358-979323846264")
    static private let SaturdaySimulationCharUUID = CBUUID(string: "00000007-3141-5926-5358-979323846264")

    static private let WifiServiceUUID = CBUUID(string: "00010000-3141-5926-5358-979323846264")
    static private let WifiStatusCharUUID = CBUUID(string: "00010001-3141-5926-5358-979323846264")
    static private let WifiSsidPasswordCharUUID = CBUUID(string: "00010002-3141-5926-5358-979323846264")
    
//    private var connectedDevice: ConnectedDevice!
    private(set) var connectedPeripheral: CBPeripheral?
    private var connectingPeripheral: CBPeripheral?
    
    private var centralManager: CBCentralManager!
    
//    init(connectedDevice: ConnectedDevice) {
    override init() {
        super.init()
//        self.connectedDevice = connectedDevice
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Central manager changed state
        
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
            
//            central.scanForPeripherals(withServices: [BluetoothManager.SimulationServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Discovered peripheral with simulation service

        if peripheral.name == "DEVICE NAME HERE" {
            central.connect(peripheral)
            connectingPeripheral = peripheral
            central.stopScan()
        }
        
        //        central.stopScan()
        //        central.connect(peripheral, options: [CBConnectPeripheralOptionEnableAutoReconnect : true])
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Connection succeeded

        connectedPeripheral = peripheral
        connectingPeripheral = nil
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        // Connection failed
        
        central.stopScan()

//        central.connect(peripheral, options: [CBConnectPeripheralOptionEnableAutoReconnect : true])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        // Peripheral diconnected
        
        if central.state == .poweredOn {
            connectedPeripheral = nil
            connectingPeripheral = nil
            
            central.scanForPeripherals(withServices: nil)
//            central.scanForPeripherals(withServices: [BluetoothManager.SimulationServiceUUID])
        }
    }
    
    // MARK: Peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        // Discovered the peripheral's services
        
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        // Discovered the characteristics for a service
        
        switch service.uuid {
        case BluetoothManager.SimulationServiceUUID:
            for char in service.characteristics ?? [] {
                peripheral.readValue(for: char)
            }
            
        case BluetoothManager.WifiServiceUUID:
            for char in service.characteristics ?? [] {
                switch char.uuid {
                case BluetoothManager.WifiStatusCharUUID:
                    // (can read and notify)
                    peripheral.readValue(for: char)
                    peripheral.setNotifyValue(true, for: char)
                    
                case BluetoothManager.WifiSsidPasswordCharUUID:
                    // (can write)
                    return
                    
                default:
                    return
                }
            }
            
        default:
            return
        }
    }
    
    static private func decodeRawData(_ rawData: Data) -> [UInt8] {
        var array: [UInt8] = []
        
        rawData.withUnsafeBytes { pointer in
            array.append(pointer.load(fromByteOffset: 0, as: UInt8.self))
            array.append(pointer.load(fromByteOffset: 1, as: UInt8.self))
            array.append(pointer.load(fromByteOffset: 2, as: UInt8.self))
            return
        }
        
        return array
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        // Read a characteristic's value or received a notification
        
        switch characteristic.uuid {
//        case BluetoothManager.SundaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .sunday, from: BluetoothManager.decodeRawData(characteristic.value!))
//            
//        case BluetoothManager.MondaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .monday, from: BluetoothManager.decodeRawData(characteristic.value!))
//
//        case BluetoothManager.TuesdaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .tuesday, from: BluetoothManager.decodeRawData(characteristic.value!))
//
//        case BluetoothManager.WednesdaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .wednesday, from: BluetoothManager.decodeRawData(characteristic.value!))
//
//        case BluetoothManager.ThursdaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .thursday, from: BluetoothManager.decodeRawData(characteristic.value!))
//
//        case BluetoothManager.FridaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .friday, from: BluetoothManager.decodeRawData(characteristic.value!))
//
//        case BluetoothManager.SaturdaySimulationCharUUID:
//            connectedDevice.updateSimulationFromRawData(of: .saturday, from: BluetoothManager.decodeRawData(characteristic.value!))

        case BluetoothManager.WifiStatusCharUUID:
            // TODO: alert user of Wi-Fi connection or diconnection
            return
            
        default:
            return
        }
    }
}

