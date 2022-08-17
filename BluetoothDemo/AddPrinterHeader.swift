//
//  AddPrinterHeader.swift
//  BluetoothDemo
//
//  Created by apple on 2021/10/20.
//

import UIKit

class AddPrinterHeader: UBaseTableViewHeaderFooterView {

    private lazy var titleView: UIView = {
        let o = UIView()
        o.backgroundColor = .white
        return o
    }()
    
    lazy var titleLab: UILabel = {
        let o = UILabel(text: "", textColor: .disableColor, textFont: .theme12)
        return o
    }()
    
    override func configUI() {
        contentView.backgroundColor = .backgroundColor
        
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview().offset(-space)
            $0.height.equalTo(56)
        }
        contentView.layoutIfNeeded()
        titleView.cornerRadius(position: [.topLeft, .topRight], cornerRadius: 4, roundedRect: CGRect(x: 0, y: 0, width: Int(ScreenWidth)-space*2, height: 56))
        
        titleView.addSubview(titleLab)
        titleLab.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview().offset(-space)
        }
    }
}
