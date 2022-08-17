//
//  BluetoothManager.swift
//  ScannerView
//
//  Created by apple on 2021/7/22.
//

import CoreBluetooth

protocol BluetoothProtocol {
    func state(state: Bluetooth.State)
    func list(list: [Bluetooth.Device])
    func current(current: CBPeripheral?)
    func value(data: Data)
    func didWrite(success: Bool)
}

final class Bluetooth: NSObject {
    static let shared = Bluetooth()
    // MARK- 打印机类型
    // 22.03.10：2022年3月之前采购的PDD【对型号PDD-520-精确判断】走CPCL打印；2022年3月之后采购的PDD 走图片打印【型号较2022年3月之前采购的PDD-520-有所区分，为PDD-520BT-xxx】
    static func getPrinterType(name: String) -> String? {
        return ["PDD-520-", "PDD", "CS3", "CC3", "M320"].first(where: { name.contains($0) })
    }
    var delegate: BluetoothProtocol?
    
    var peripherals = [Device]()
    var current: CBPeripheral? { didSet { delegate?.current(current: current) } }
    var state: State = .unknown { didSet { delegate?.state(state: state) } }
    
    private var manager: CBCentralManager?
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var printerType: String?
    
    private override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: .none)
        manager?.delegate = self
    }
    
    func connect(_ peripheral: CBPeripheral) {
        if current != nil {
            guard let current = current else { return }
            manager?.cancelPeripheralConnection(current)
            manager?.connect(peripheral, options: nil)
        } else { manager?.connect(peripheral, options: nil) }
    }
    
    func disconnect() {
        guard let current = current else { return }
        manager?.cancelPeripheralConnection(current)
    }
    
    func startScanning() {
        peripherals.removeAll()
        print("manager?.statepoweredOn ===== \(manager?.state == .poweredOn)")
        // 如果蓝牙可用，就开始扫描设备， 通过下面方法
        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    func stopScanning() {
        peripherals.removeAll()
        manager?.stopScan()
    }
    
    func send(_ value: [UInt8]) { // value = [0x0A, 0x0B, 0x1B, ....]
        guard let characteristic = writeCharacteristic else { return }
        // STEP4: 用存下的characteristic写数据
//        if printerType == "CS3" || printerType == "CC3" {
            current?.writeValue(Data(value), for: characteristic, type: .withResponse)
//        } else {
//            current?.writeValue(Data(value), for: characteristic, type: .withoutResponse)
//        }
        print("send ----------------- > \(value)")
    }
    
    enum State { case unknown, resetting, unsupported, unauthorized, poweredOff, poweredOn, error, connected, disconnected }
    
    struct Device: Identifiable {
        let id: Int
        let rssi: Int
        let uuid: String
        let peripheral: CBPeripheral
    }
}

// 初始化的时候回调用此代理方法检查蓝牙状态 [主要用于连接]
extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch manager?.state {
        case .unknown: state = .unknown // 蓝牙系统错误
        case .resetting: state = .resetting // 请重新开启手机蓝牙
        case .unsupported: state = .unsupported // 该手机不支持蓝牙
        case .unauthorized: state = .unauthorized // 蓝牙验证失败
        case .poweredOff: state = .poweredOff // 蓝牙没开启，直接到设置
        case .poweredOn: state = .poweredOn
        default: state = .error
        }
    }
    // ---------------- 找到了对于的服务 ----------------
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uuid = String(describing: peripheral.identifier)
        let filtered = peripherals.filter{$0.uuid == uuid}
        if filtered.count == 0 {
            guard let _ = peripheral.name else { return }
            let new = Device(id: peripherals.count, rssi: RSSI.intValue, uuid: uuid, peripheral: peripheral)
            peripherals.append(new)
            delegate?.list(list: peripherals)
        }
    }
    
    // ---------------- 连接外设成功和失败的代理 --------------- //
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // stops scanning for peripheral
        state = .disconnected
        print("connect peripheral successfully")
        
        // TODO : clears the data that we may already have
        
        current = peripheral
        state = .connected
        // sets the peripheral delegate
        peripheral.delegate = self
        // asks the peripheral to discover the service
//        peripheral.discoverServices(nil)
        
        // STEP1: 指定扫描FF00
        let name = (peripheral.name ?? "").uppercased()
        printerType = Bluetooth.getPrinterType(name: name)
        if let uuids = printerServices[printerType ?? ""] {
            let uuid = CBUUID(string: uuids.0)
            print("printerType ---- \(printerType ?? "") uuid ----- \(uuid)")
            peripheral.discoverServices([uuid])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connect peripheral failed:\(error!).errer message")
        
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        current = nil
        state = .disconnected
    }
}

extension Bluetooth: CBPeripheralDelegate {
    // ---------------- 发现服务的代理 [主要用于和peripheral进行交互] -----------------
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("service found with UUID --- > \(service.uuid)")
            // Discovers the characteristics for a given service
            // STEP2: 扫描service中的characteristics
            let name = (peripheral.name ?? "").uppercased()
            printerType = Bluetooth.getPrinterType(name: name)
            if let uuids = printerServices[printerType ?? ""] {
                let uuid = CBUUID(string: uuids.1)
                let uuidNotify = CBUUID(string: uuids.2)
                print("printerType ---- \(printerType ?? "") uuid ----- \(uuid)")
                peripheral.discoverCharacteristics([uuid, uuidNotify], for: service)
            }
        }
    }
    // ---------------- 找到对于的characteristics 调用服务特性的代理 -------------------- //
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if(characteristic.properties.intersection(.broadcast).rawValue != 0){
                // broadcast
                print("characteristic found with properties --- > \(service.uuid)/broadcast")
            }
            if(characteristic.properties.intersection(.read).rawValue != 0){
                // read
                print("characteristic found with properties --- > \(service.uuid)/read")
            }
            if(characteristic.properties.intersection(.writeWithoutResponse).rawValue != 0){
                // writeWithoutResponse
                print("characteristic found with properties --- > \(service.uuid)/write")
                writeCharacteristic = characteristic
            }
            if(characteristic.properties.intersection(.write).rawValue != 0){
                // write
                print("characteristic found with properties --- > \(service.uuid)/write")
                writeCharacteristic = characteristic
            }
            if(characteristic.properties.intersection(.notify).rawValue != 0){
                // notify
                print("characteristic found with properties --- > \(service.uuid)/notify")
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if(characteristic.properties.intersection(.indicate).rawValue != 0){
                // indicate
                print("characteristic found with properties --- > \(service.uuid)/indicate")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    // ---------------- 写入数据的回调 -------------------- //
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {}
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("\nError while writing on Characteristic:\n\(characteristic).error Message:")
            delegate?.didWrite(success: false)
        } else {
            delegate?.didWrite(success: true)
            print("\nSuccessfully sent to bluetooth device")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) { }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // response
        guard let value = characteristic.value else { return }
        delegate?.value(data: value)
    }
}
