//
//  Global.swift
//  BluetoothDemo
//
//  Created by apple on 2022/4/13.
//

import UIKit
import Foundation

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let space = 16
let countDownNum = 60


var isIphoneX: Bool {
    var isIphoneX = false
    if #available(iOS 11.0, *) {
        let bottom : CGFloat = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        isIphoneX = bottom > 0.0
    }
    return isIphoneX
}

public var safeBottomHeight : CGFloat {
    var bottomH : CGFloat = 0.0
    if isIphoneX {
        bottomH = 34.0
    }
    return bottomH
}
