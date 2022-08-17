//
//  AddPrinterCell.swift
//  BluetoothDemo
//
//  Created by apple on 2021/10/20.
//

import UIKit

class AddPrinterCell: UBaseTableViewCell {
    
    var list: BluetoothList? {
        didSet {
            guard let list = list else { return }
            
            peripheralName.text = list.name
            peripheralIdentifier.text = list.uuid
            connectState.text = list.isCurrent ?  "已连接" : "" 
            connectState.font = list.isCurrent ? .bold12 : .theme12
        }
    }
    lazy var baseView: UIView = {
        let o = UIView()
        o.backgroundColor = .white
        return o
    }()
    
    // 打印机名字
    lazy var peripheralName: UILabel = {
        let o = UILabel(text: "", textColor: .black, textFont: .theme14)
        return o
    }()
    
    // 连接状态
    lazy var connectState: UILabel = {
        let o = UILabel(text: "", textColor: UIColor.lightGray, textFont: .theme12)
        return o
    }()
    
    // 打印机 identifier
    lazy var peripheralIdentifier: UILabel = {
        let o = UILabel(text: "", textColor: .disableColor, textFont: .theme14)
        return o
    }()
    
    private lazy var line: UILabel = {
        let o = UILabel()
        o.backgroundColor = .lineColor
        return o
    }()

    override func configUI() {
        contentView.backgroundColor = .backgroundColor
        
        contentView.addSubview(baseView)
        baseView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview().offset(-space)
            $0.bottom.equalToSuperview()
        }
        
        baseView.addSubview(line)
        line.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        baseView.addSubview(peripheralName)
        peripheralName.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(space)
        }
        
        baseView.addSubview(connectState)
        connectState.snp.makeConstraints {
            $0.centerY.equalTo(peripheralName.snp.centerY)
            $0.trailing.equalToSuperview().offset(-space)
        }
        
        baseView.addSubview(peripheralIdentifier)
        peripheralIdentifier.snp.makeConstraints {
            $0.top.equalTo(peripheralName.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview().offset(-space)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
