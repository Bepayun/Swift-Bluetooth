//
//  BluetoothObject.swift
//
//
//  Created by apple on 2021/7/31.
//

import Foundation
import CoreBluetooth
import UIKit

// MARK: - 蓝牙通知Key
extension NSNotification.Name {
    static let bluetoothFound = NSNotification.Name("bluetoothFound")
    static let bluetoothScanning = NSNotification.Name("bluetoothScanning")
    static let bluetoothState = NSNotification.Name("bluetoothState")
    static let bluetoothWriteState = NSNotification.Name("bluetoothWriteState")
}

class BluetoothObject: BluetoothProtocol {
    
    static let shared = BluetoothObject()
    enum printType { case data, string }
    /**
     * data: 图片传输（打印图片）
     * string: 文本传输（CPCL打印）
     */
    enum State { case unknown, error, connected, disconnected }
    /**
     * none: 空闲（盒盖有纸）
     * writing: 走纸或者打印中
     * finished: 打印完成
     * outofpaper: 缺纸
     * openlid: 开盖
     */
    enum WriteState { case none, writing, finished, outofpaper, openlid, fail }
        
    var bluetooth = Bluetooth.shared
    public var state: State = .unknown // 连接状态
    {
        didSet {
            NotificationCenter.default.post(name: .bluetoothState, object: self, userInfo: ["state": state])
        }
    }
    
    public var scanning: Bool = false // 当前正在扫描
    {
        didSet {
            NotificationCenter.default.post(name: .bluetoothScanning, object: self, userInfo: ["scanning": scanning])
        }
    }
    
    var tryConnecting: String? // 尝试连接的目标（来自已记录的列表，可能还暂时未被扫描到）
    public var list: [Bluetooth.Device] = [] // 扫描列表
    {
        didSet {
            NotificationCenter.default.post(name: .bluetoothFound, object: nil)
        }
    }
    public var response: Data = Data() // notify的返回值
    public var current: CBPeripheral? // 当前连接的设备
    var timer = Timer() // 扫描超时计时器
    
    /* ===== 打印控制 ===== */
    public var writeState: WriteState = .none // 打印机状态
    {
        didSet {
            NotificationCenter.default.post(name: .bluetoothWriteState, object: self, userInfo: ["writeState": writeState, "sended" : sended])
        }
    }
    var writeQueue: [(Any, String, printType)] = [] // 结构：(Any, String, printType) = (打印内容(string、data)，运单列表, 打印类型)
    var sended: [String] = [] // 已经发送给打印机的运单列表
    var writeTimer = Timer() // 打印状态轮询计时器

    init() {
        bluetooth.delegate = self
    }
    
    // ===== 蓝牙生命周期 =====
    func startScanning() {
        scanning = true
        // 清空等待连接
        tryConnecting = nil
        // 开始扫描（该操作会清空已有列表重新开始）
        bluetooth.startScanning()
        
        // 30s后停止
        timer.invalidate()
        timer = Timer.init(timeInterval: 30, repeats: false) { timer in
//            withAnimation {
                self.stopScanning()
//            }
        }
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func continueScanning() {
        if(!scanning){
            // 如果没在扫描，则开启扫描
            scanning = true
            bluetooth.startScanning()
        }
        
        // 重置30s等待时间
        timer.invalidate()
        timer = Timer.init(timeInterval: 30, repeats: false) { timer in
//            withAnimation {
                self.stopScanning()
//            }
        }
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func stopScanning() {
        tryConnecting = nil
        scanning = false
        bluetooth.stopScanning()
    }
    
    func connect(_ peripheral: CBPeripheral) {
        bluetooth.connect(peripheral)
        // 清空和当前连接有关的状态
        tryConnecting = nil
        self.resetQueue()
    }
    
    func disconnect() {
        bluetooth.disconnect()
        // 清空和当前连接有关的状态
        tryConnecting = nil
        self.resetQueue()
    }
    
    private func connectFromList(_ uuid: String) -> Bool {
        if let device = self.list.first(where: { $0.uuid == uuid}) {
            self.connect(device.peripheral)
            self.stopScanning()
            return true
        }
        
        return false
    }
    
    func tryConnect(_ uuid: String) {
        // 如果已经在列表中就直接连接
        if(connectFromList(uuid)){
            
        } else {
            // 如果还不在列表中，则记录下uuid，一旦扫描到就自动连接
            tryConnecting = uuid
            // 继续扫描（重置10s等待时间）
            self.continueScanning()
        }
    }
    
    func state(state: Bluetooth.State) {
        switch state {
        case .unknown:
            self.state = .unknown
            print("◦ .unknown")
        case .resetting:
            self.state = .error
            print("◦ .resetting")
        case .unsupported: // 不支持
            self.state = .error
            print("◦ .unsupported")
        case .unauthorized: // 未授权
            self.state = .error
            print("◦ bluetooth disabled, enable it in settings")
        case .poweredOff:
            self.state = .error
            print("◦ turn on bluetooth")
        case .poweredOn:
            self.state = .unknown
            print("◦ everything is ok")
        case .error:
            self.state = .error
            print("• error")
        case .connected:
            self.state = .connected
            print("◦ connected to \(bluetooth.current?.name ?? "")")
        case .disconnected:
            self.state = .disconnected
            print("◦ disconnected")
        }
    }
    
    private func startValidate(_ immidiate: Bool) {
        // 1s后尝试发送验证请求(immidiate == true时则0s后直接开始)
        writeTimer.invalidate()
        writeTimer = Timer.init(timeInterval: immidiate ? 0 : 1, repeats: false) { timer in
            #if DEBUG
            print("startValidate ----------------- > \(self.writeQueue.count) remaining")
            #endif
            // 发送验证请求
            let bluetoothName = (self.current?.name ?? "").uppercased()
            if bluetoothName.contains("PDD") {
                // PDD: [0x1b, 0x68]
                self.bluetooth.send([0x1b, 0x68])
            } else if bluetoothName.contains("CS3") || bluetoothName.contains("CC3") {
                // CS3: [0x1D, 0x99]
                self.bluetooth.send([0x1D, 0x99])
            } else if bluetoothName.contains("M320") {
                // GP: [0x1B, 0x21, 0x3F] 验证请求后面要加回车 0x0D 0x0A
                self.bluetooth.send([0x1B, 0x21, 0x3F, 0x0D, 0x0A])
            }
        }
        RunLoop.current.add(writeTimer, forMode: .default)
    }
    
    private func startPrint() {
        if writeQueue.count > 0 {
            print("startPrint ----------------- > \(writeQueue.count) remaining")
            // 还有需要打印的
            writeState = .writing
            // 开始打印当前队列第一个
//            bluetooth.send(Array(writeQueue[0].utf8))
            let curItem: (Any, String, printType) = writeQueue[0]
            writeQueue.removeFirst()
            /**
             * iOS蓝牙分包，MTU
             * BLE的传输长度最大是187个bytes:只能传输185个，另外ATT协议得占用2个
             * 有的不支持185，蓝牙5.0以下是这个,23个bytes.
             */
            
            switch curItem.2 {
            case .data:
                let sendData = curItem.0 as! Data
                var printed = 0
                while printed < sendData.count {
                    let maxL = printed + 185 > sendData.count ? sendData.count : printed + 185
                    let subData = sendData.subdata(in: printed..<maxL)
                    bluetooth.send(Array(subData))
                    printed = printed + 185
                }
                
            case .string:
                let sendStr = curItem.0 as! String
                var printed = 0
                while printed < sendStr.count {
                    let left = sendStr.index(sendStr.startIndex, offsetBy: printed),
                        right = sendStr.index(sendStr.startIndex, offsetBy: min(sendStr.count, printed + 185))
                    bluetooth.send(Array(String(sendStr[left..<right]).utf8))
                    printed = printed + 185
                }
            }
            
            if writeState != .fail {
                // 把发送的这个运单号存下来
                sended.append(curItem.1)
            }
            self.startValidate(false)
        } else {
            // 打印完了
            writeState = .finished
        }
    }
    
    func resetQueue(_ toState: WriteState) {
        print("resetQueue ----------------- > \(toState)")
        writeState = toState
        writeQueue = []
        writeTimer.invalidate()
    }
    
    func resetQueue() {
        self.resetQueue(.none)
    }
    
    // ******************** 打印机发送数据进行UInt8 & Map ******************** //
    func sendString(_ str: String, _ billNo: String) {
        // 检测，如果这个订单号在已打印或者即将打印的队列中，则舍弃
        if sended.contains(billNo) || writeQueue.contains(where: { $0.1 == billNo }) {
            // 已打印
            #if DEBUG
            print("sendString ----------------- > billNo: \(billNo) DUPLICATED")
            #endif
        }
        
        writeQueue.append((str, billNo, .string))
        #if DEBUG
        print("sendString ----------------- > str: \(str) billNo: \(billNo)")
        print("sendString ----------------- > queue: \(writeQueue.count)")
        #endif
        // 从检测打印状态开始
        writeState = .none
        self.startValidate(true)
    }
    
    // ******************** 打印机发送data数据进行UInt8 & Map ******************** //
    func writeData(_ data: Data, _ billNo: String) {
        // 检测，如果这个订单号在已打印或者即将打印的队列中，则舍弃
        if sended.contains(billNo) || writeQueue.contains(where: { $0.1 == billNo }) {
            // 已打印
            #if DEBUG
            print("writeData ----------------- > billNo: \(billNo) DUPLICATED")
            #endif
        }
        writeQueue.append((data, billNo, .data))
        #if DEBUG
        print("writeData ----------------- > str: \(data) billNo: \(billNo)")
        print("writeData ----------------- > queue: \(writeQueue.count)")
        #endif
        // 从检测打印状态开始
        writeState = .none
        self.startValidate(true)
    }
    
    // TODO: QR后期确认
    static let NAME_REG = try! NSRegularExpression(pattern: "^(PDD\\-520|CS3|CC3|M320\\_D34B|QR)", options: .caseInsensitive)
    
    func list(list: [Bluetooth.Device]) {
//        self.list = list
        self.list = list.filter({ item in
             if current != nil && item.peripheral.identifier.uuidString == current!.identifier.uuidString { return false }
//            item.peripheral.name!.contains("PDD-520")
            let name: String = item.peripheral.name ?? ""
//            print("printer name name name ===== \(name)")
            return BluetoothObject.NAME_REG.firstMatch(in: name, options:[], range: NSRange(location:0, length: name.utf16.count)) !== nil
        })
        
        self.list.forEach({
            #if DEBUG
            print("UUID: \($0.uuid) --- \(String(describing: $0.peripheral.identifier))")
            #endif
        })
        
        
        if tryConnecting != nil {
            // 正想尝试连接某个uuid的设备
            if connectFromList(tryConnecting!) {
                // 连接成功
                tryConnecting = nil
            }
        }
    }
    
    func current(current: CBPeripheral?) {
        self.current = current
    }
    
    func value(data: Data) {
        response = data

        if writeState == .fail {
            // 已经失败，不管返回结果
            return
        }

        let bluetoothName = (current?.name ?? "").uppercased()
        // 打印中或者等待处理问题中，根据返回值判断当前状态
        if bluetoothName.contains("PDD") {
            // PDD
            #if DEBUG
            print("response(\(writeState)) ----------------- PDD > \(response[0])")
            #endif
            self.PDDResponse()
        } else if bluetoothName.contains("CS3") || bluetoothName.contains("CC3") {
            // CS3 CC3
            #if DEBUG
            print("response(\(writeState)) ----------------- CS3 > \(response[2])")
            #endif
            self.CS3Response()
        } else if bluetoothName.contains("M320") {
            // GP
            #if DEBUG
            print("response(\(writeState)) ----------------- GP M > \(response[0])")
            #endif
            self.GPResponse()
        }
    }

    func PDDResponse() {
        // PDD response state
        if response[0] == 0 { // 空闲
            // 可以开始打印
            self.startPrint()
        } else if response[0] == 79 { // 错误的代码
            // 继续验证状态
            self.startValidate(false)
        } else if response[0] & 0x06 == 0x06 { // 开盖
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .openlid
            self.startValidate(false)
        } else if response[0] & 0x02 == 0x02 || response[0] & 69 == 69 { // 缺纸
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .outofpaper
            self.startValidate(false)
        } else if response[0] & 0x01 == 0x01  { // 正在打印中
            // 恢复打印状态
            writeState = .writing
            self.startValidate(false)
        }
    }
    
    func CS3Response() {
        // CS3 response state
        if response[2] == 0 { // 正常
            // 可以开始打印
            self.startPrint()
        } else if response[2] & 0x02 == 0x02 { // 开盖
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .openlid
            self.startValidate(false)
        } else if response[2] & 0x01 == 0x01 { // 缺纸
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .outofpaper
            self.startValidate(false)
        } else if response[2] & 0x10 == 0x10  { // 电量低
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .outofpaper // TODO: 电量低的独有状态
        } else if response[2] & 0x20 == 0x20  { // 正在打印中
            // 恢复打印状态
            writeState = .writing
            self.startValidate(false)
        }
    }
    
    func GPResponse() {
        // GP response state
        if response[0] & 0x00 == 0x00 { // 正常待机
            // 可以开始打印
            self.startPrint()
        } else if response[0] & 0x01 == 0x01 { // 开盖
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .openlid
            self.startValidate(false)
        } else if response[0] & 0x04 == 0x04 || response[0] & 0x05 == 0x05 { // 缺纸
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .outofpaper
            self.startValidate(false)
        } else if response[0] & 0x08 == 0x08  { // 无碳带
            // 记录状态，等待打印继续启动（延迟验证状态已决定是否继续打印）
            writeState = .outofpaper // TODO: 无碳带的独有状态
        } else if response[0] & 0x20 == 0x20  { // 正在打印中
            // 恢复打印状态
            writeState = .writing
            self.startValidate(false)
        }
    }
    
    func didWrite(success: Bool) {
        // TODO: 根据didWrite是否成功决定分包是否需要重新发送
        if !success {
            resetQueue(.fail)
        }
    }
}
