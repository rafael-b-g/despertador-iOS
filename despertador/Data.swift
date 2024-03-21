//
//  ConnectedDevice.swift
//  despertador
//
//  Created by Rafael Guimarães on 18/03/24.
//

import Foundation
import Observation

@Observable class ConnectedDevice {
    private var bluetoothManager = BluetoothManager()
    var isConnected: Bool {
        if let peripheral = bluetoothManager.connectedPeripheral {
            return peripheral.state == .connected
        } else {
            return false
        }
    }
    private(set) var lightIntensity: Float = 0
    private(set) var simulations: [WeekDay: Simulation] = [
        .sunday: Simulation(),
        .monday: Simulation(),
        .tuesday: Simulation(),
        .wednesday: Simulation(),
        .thursday: Simulation(),
        .friday: Simulation(),
        .saturday: Simulation(),
    ]
    
//    init() {
//        bluetoothManager = BluetoothManager(connectedDevice: self)
//    }
    
    func updateSimulation(of day: WeekDay, endTime: UInt16, duration: UInt8 = 40) {
        simulations[day] = Simulation(
            duration: duration,
            endTime: endTime,
            isEnabled: true
        )
    }
    
    func updateSimulationFromRawData(of day: WeekDay, from rawData: [UInt8]) {
        let endTimeUTC = UInt16(rawData[2]) << 8 | UInt16(rawData[3])
        
        simulations[day] = Simulation(
            duration: rawData[0] == 0 ? simulations[day]!.duration : rawData[0],
            endTime: endTimeUTC + UInt16((TimeZone.current.secondsFromGMT() / 60)),
            isEnabled: rawData[0] != 0
        )
    }
    
    func enableSimulation(of day: WeekDay) {
        simulations[day]?.isEnabled = true
    }
    
    func disableSimulation(of day: WeekDay) {
        simulations[day]?.isEnabled = false
    }
    
    func setLightIntensity(_ newLightIntensity: Float) {
        lightIntensity = newLightIntensity
    }
}

struct Simulation {
    var duration: UInt8 = 40
    var endTime: UInt16 = 0
    var isEnabled: Bool = false
    
    var endTimeUTC: Int { Int(endTime) - (TimeZone.current.secondsFromGMT() / 60) }
}
