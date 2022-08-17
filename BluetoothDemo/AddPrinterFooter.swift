//
//  AddPrinterFooter.swift
//  BluetoothDemo
//
//  Created by apple on 2021/10/20.
//

import UIKit

class AddPrinterFooter: UBaseTableViewHeaderFooterView {
    
    // 点击回调
    var searchActiveHandler:(()->Void)?
    
    @objc func searchActive() {
        guard let searchActiveHandler = searchActiveHandler else { return }
        searchActiveHandler()
    }
    
    // 搜索
    private lazy var searchView: UIView = {
        let o = UIView(backgroundColor: .white, cornerRadius: 4)
        o.tapGestureRecognizer(target: self, action: #selector(searchActive))
        return o
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let o = UIActivityIndicatorView()
        // 停止后，隐藏菊花
        o.hidesWhenStopped = true
        o.style = UIActivityIndicatorView.Style.gray
        return o
    }()
    
    lazy var searchLab: UILabel = {
        let o = UILabel(text: "", textColor: .disableColor, textFont: .theme14, textAlignment: .center)
        return o
    }()
    
    override func configUI() {
        contentView.backgroundColor = .backgroundColor
        
        // 搜索
        contentView.addSubview(searchView)
        searchView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(space)
            $0.trailing.equalToSuperview().offset(-space)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        searchView.addSubview(searchLab)
        searchLab.snp.makeConstraints {
            $0.center.equalTo(searchView.snp.center)
        }
        
        searchView.addSubview(self.activityView)
        activityView.snp.makeConstraints {
            $0.centerY.equalTo(searchLab.snp.centerY)
            $0.leading.equalTo(searchLab.snp.trailing).offset(3)
        }
    }
    
    // MARK: - 刷新搜索状态
    func searchingState() {
        searchLab.text = "搜索中"
        searchLab.textColor = .disableColor
        // 开启旋转动画
        activityView.startAnimating()
    }
    // MARK: - 刷新搜索状态
    func searchAgainState() {
        searchLab.text = "重新搜索"
        searchLab.textColor = .themeColor
        // 关闭旋转动画
        activityView.stopAnimating()
        // 停止后，隐藏菊花
        activityView.hidesWhenStopped = true
    }
}
