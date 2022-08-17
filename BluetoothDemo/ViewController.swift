//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by apple on 2022/4/1.
//

import UIKit
import SnapKit
import CoreBluetooth

struct BluetoothList {
    var name: String
    var uuid: String
    var peripheral: CBPeripheral
    var isCurrent: Bool = false
}

class ViewController: UIViewController {
    
    var response: PrintDataResponse = PrintDataResponse()
    
    var bluetooth = BluetoothObject.shared
    var list: [BluetoothList] = [ ]
    var scanning: Bool = true // 第一次进入显示正在搜索
    
    var bluetoothPrintMode = BluetoothPrintMode.shared
    var printerType: String? // 打印机型号
    
    // MARK: 打印点击事件
    @objc func printActive(sender: UIButton) {
        
        if bluetooth.state == .connected {
            let bluetoothName = (bluetooth.current?.name ?? "").uppercased()
            printerType = Bluetooth.getPrinterType(name: bluetoothName)
        } else {
            ProgressHUD.showText("未连接打印机")
            return
        }
        
        if sender.tag == 500 { // 文本打印
            print("文本打印")
            if (self.printerType == "PDD-520-") { // PDD-520-**** 走文本打印
                self.bluetoothPrintMode.CPCLAddressSplicing(response: response)
                // 打印数据写入对数据的处理
                let str: String = self.bluetoothPrintMode.CPCLPrintDataWriting(response: response, printerType: self.printerType)
                self.bluetooth.sendString(str, response.waybillNo)
            
            } else {
                ProgressHUD.showText("不支持文本打印")
            }
            
        } else { // 图片打印
            print("图片打印")
            if (self.printerType == "PDD-520-") {
                ProgressHUD.showText("不支持图片打印")
                return
            }
//            let faceSheetView = FaceSheetView()
//            // 耗材指定规格：76*130mm
//            // 576 * 1000:打印面单尺寸 规则写死 点对点传输 原始分辨率与打印机的分辨率匹配，防止像素的损失
//            faceSheetView.frame = CGRect(x: 0, y: safeBottomHeight+10, width: 576, height: 1000)
//            faceSheetView.printData = response
//            faceSheetView.layer.masksToBounds = true
//            faceSheetView.layoutIfNeeded()
//            CATransaction.flush()
//
//            let datas: Data = self.bluetoothPrintMode.getFaceSheetMode(faceSheetView: faceSheetView, printerType: self.printerType)
//
//            faceSheetView.removeFromSuperview();
            
            
            // PDF
            let filename = "test"
            let datas: Data = self.bluetoothPrintMode.getPrintPDFMode(pathFileName: filename, printerType: self.printerType)
//
            self.bluetooth.writeData(datas, response.waybillNo)
        }
        
    }
    
    // MARK: -  更新蓝牙读写状态
    @objc func updateWriteState(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let isWriteState = userInfo["writeState"] as! BluetoothObject.WriteState
        let sended = userInfo["sended"] as! [String]
        print("isWriteState ===== \(isWriteState)")
        print("sended ===== \(sended)")
        
        switch bluetooth.writeState {
        case .finished:
            ProgressHUD.showText("打印成功")
            // 根据蓝牙记录的已打印列表移动到”已打印“
            print("confirm \(sended)")
            // 清空记录
            bluetooth.sended = []
        case .writing:
            ProgressHUD.showText("打印中")
            
        case .fail:
            ProgressHUD.showText("打印失败")
            print("confirm \(sended)")
            // 清空记录
            bluetooth.sended = []
        case .openlid, .outofpaper:
            ProgressHUD.showText("缺纸或开盖")
            
        default: // .validating, .writing, .none
            break
        }
    }
    
    // MARK: 点击连接打印机
    @objc func connectActive() {
        tableView.isHidden = false
        bluetooth.startScanning()
        updateList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - 获取最新蓝牙设备列表
    @objc func updateList() {
        list = bluetooth.list.map({ device in
            let name = device.peripheral.name ?? ""
            let uuid = String(describing: device.peripheral.identifier)
            return BluetoothList(name: name, uuid: uuid, peripheral: device.peripheral)
        })
        
        if bluetooth.current != nil {
            list.insert(BluetoothList(name: bluetooth.current!.name ?? "", uuid: String(describing: bluetooth.current!.identifier), peripheral: bluetooth.current!, isCurrent: true), at: 0)
        }
        
        tableView.reloadData()
    }
    
    // MARK: -  更新蓝牙Scanning
    @objc func updateScanning(notification: Notification) {
        guard let isScanning = notification.userInfo?["scanning"], isScanning != nil else {return}
        self.scanning = isScanning as! Bool
        
        tableView.reloadData()
    }
    
    // MARK: -  更新蓝牙连接状态
    @objc func updateState(notification: Notification) {
        guard let isState = (notification.userInfo?["state"] as? BluetoothObject.State) else {return}
        print("isState ===== \(isState)")
        
        if bluetooth.state == .connected {
            // 连接成功过后跳转到我的打印机列表
            navigationController?.popViewController(animated: true)
            ProgressHUD.showText("连接成功")
            
        } else if bluetooth.state == .disconnected {
            ProgressHUD.showText("断开")
        } else {
            ProgressHUD.showText("连接失败")
        }

        self.updateList()
    }
    
    
    private lazy var tableView: UITableView = {
        let tw = UITableView(frame: .zero, style: .plain)
        tw.backgroundColor = .backgroundColor
        tw.delegate = self
        tw.dataSource = self
        tw.separatorStyle = .none
        tw.showsVerticalScrollIndicator = false
        tw.showsHorizontalScrollIndicator = false
//        tw.isScrollEnabled = false;
        tw.estimatedRowHeight = 150
        tw.register(headerFooterViewType: AddPrinterHeader.self)
        tw.register(cellType: AddPrinterCell.self)
        tw.register(headerFooterViewType: AddPrinterFooter.self)
        
        if #available(iOS 15.0, *) {
            tw.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tw.isHidden = true
        return tw }()
    
    private lazy var connectPrinter: UIButton = {
        let o = UIButton(type: .custom)
        o.backgroundColor = .systemPink
        o.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        o.setTitle("点击连接打印机", for: .normal)
        o.setTitleColor(.black, for: .normal)
        o.addTarget(self, action: #selector(connectActive), for: .touchUpInside)
        o.layer.cornerRadius = 8
        
        return o
    }()
    
    private lazy var printerLab: UILabel = {
        let o = UILabel()
        o.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        o.textAlignment = .center
        o.textColor = .black
        o.backgroundColor = .lightGray
        o.layer.masksToBounds = true
        o.layer.cornerRadius = 8
        
        return o
    }()
    
    private lazy var cpclBtn: UIButton = {
        let o = UIButton(type: .custom)
        o.backgroundColor = .systemPink
        o.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        o.setTitle("文本打印", for: .normal)
        o.setTitleColor(.black, for: .normal)
        o.tag = 500
        o.addTarget(self, action: #selector(printActive), for: .touchUpInside)
        o.layer.cornerRadius = 8
        
        return o
    }()
    
    private lazy var pictureBtn: UIButton = {
        let o = UIButton(type: .custom)
        o.backgroundColor = .systemPink
        o.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        o.setTitle("图片打印", for: .normal)
        o.setTitleColor(.black, for: .normal)
        o.tag = 501
        o.addTarget(self, action: #selector(printActive), for: .touchUpInside)
        o.layer.cornerRadius = 8
        
        return o
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: .bluetoothFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateScanning), name: .bluetoothScanning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateState), name: .bluetoothState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWriteState), name: .bluetoothWriteState, object: nil)
        
        self.configUI()
    }

    func configUI() {
        view.addSubview(connectPrinter)
        connectPrinter.snp.makeConstraints {
            $0.top.equalTo(200)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 200, height: 60))
        }

        view.addSubview(printerLab)
        printerLab.snp.makeConstraints {
            $0.top.equalTo(connectPrinter.snp_bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(connectPrinter)
        }

        view.addSubview(cpclBtn)
        cpclBtn.snp.makeConstraints {
            $0.top.equalTo(printerLab.snp_bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(connectPrinter)
        }

        view.addSubview(pictureBtn)
        pictureBtn.snp.makeConstraints {
            $0.top.equalTo(cpclBtn.snp_bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(connectPrinter)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(pictureBtn.snp_bottom).offset(15)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: AddPrinterCell.self)
        
        if indexPath.row == 1 {
            cell.layoutIfNeeded()
            cell.baseView.cornerRadius(position: [.bottomLeft, .bottomRight], cornerRadius: 4, roundedRect: CGRect(x: 0, y: 0, width: Int(ScreenWidth)-space*2, height: 68))
        }
        if indexPath.row < list.count {
            cell.list = list[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = list[indexPath.row].peripheral
        bluetooth.connect(peripheral)
        // 记录蓝牙设备
//        guard viewContext != nil else { return }
        let name = peripheral.name ?? ""
        let uuid = peripheral.identifier.uuidString
        
        printerLab.text = "\(name)"
        
//        let printerType: String? = Bluetooth.getPrinterType(name: name)
//        if printerType == "PDD-520-" {
//            AnalyzeTool.logEvent(String.PrintPddOldUseEvent)
//        }
//
//        let fetchRequest = MyPrinterEntity.fetchRequest()
//        do {
//            // 取出已经有记录的设备
//            let printerList = try viewContext!.fetch(fetchRequest)
//            if let saveEntity = printerList.first(where: { $0.uuid == uuid }) {
//                // 存储列表里已有相同uuid，则更新name
//                saveEntity.name = name
//            } else {
//                // 存储列表里无该uuid，添加新存储项目
//                let newPrinter = MyPrinterEntity(context: viewContext!)
//                newPrinter.name = name
//                newPrinter.uuid = uuid
//            }
//            do {
//                // 尝试保存
//                try viewContext!.save()
//            } catch let error as NSError {
//                // 存储失败
//                print("Core Data save error \(error), \(error.userInfo)")
//            }
//        } catch let error as NSError {
//            print("Core Data fetch error: \(error), \(error.userInfo)")
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(AddPrinterHeader.self)
        head?.titleLab.text = "附近的蓝牙设备"
        
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let foot = tableView.dequeueReusableHeaderFooterView(AddPrinterFooter.self)
        
        if self.scanning {
            foot?.searchingState()
        } else {
            foot?.searchAgainState()
        }
        foot?.searchActiveHandler = {
            foot?.searchingState()
            self.bluetooth.startScanning()
        }
        return foot
    }
}
