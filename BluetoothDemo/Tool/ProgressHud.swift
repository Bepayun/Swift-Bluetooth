//
//  File.swift
//  BluetoothDemo
//
//  Created by apple on 2022/4/13.
//

import UIKit
import MBProgressHUD
import SwiftyGif

class ProgressHUD: MBProgressHUD {
    
    class func showText(_ text: String?) {
        // 立即隐藏，保证每次只显示一种状态
        hide()
        let view = viewWithShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .textColor.withAlphaComponent(0.88)
        hud.label.text = text ?? ""
        hud.label.textColor = .white
        hud.contentColor = .white
        hud.label.numberOfLines = 0
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    class func viewWithShow() -> UIView {
        let window = UIApplication.shared.delegate?.window!
        return window!
    }
    
    class func showLoading(_ tip: String = "") {
        let view = viewWithShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView
        
        let customImg = GifImageView()
        do {
            let gif = try UIImage(gifName: "refresh_logo.gif")
            customImg.setGifImage(gif, loopCount: -1)
        } catch {
            print(error)
        }
        hud.margin = 6
        hud.customView = customImg
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .textColor.withAlphaComponent(0.88)
        hud.label.text = tip
        hud.label.textColor = .white
        hud.contentColor = .white
        hud.removeFromSuperViewOnHide = true
    }
    
    class func hide() {
        let view = viewWithShow()
        MBProgressHUD.hide(for: view, animated: true)
    }
}

//这里要注意
extension GifImageView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 105, height: 70)
    }
}
