//
//  UIColorExtension.swift
//  U17
//
//  Created by apple on 2022/4/1.
//

import UIKit

//MARK: 应用颜色
extension UIColor {
    class var backgroundColor: UIColor {
        return UIColor.hex(hexString: "F6F7FA")
    }
    
    class var themeColor: UIColor {
        return UIColor.hex(hexString: "062CFF")
    }
    
    class var textColor: UIColor {
        return UIColor.hex(hexString: "151741")
    }
    
    class var disableColor: UIColor {
        return UIColor.hex(hexString: "A6A6B9")
    }
    
    class var lineColor: UIColor {
        return UIColor.hex(hexString: "E8EAF3")
    }
    
    class var unselectedThemeColor: UIColor {
        return UIColor.hex(hexString: "DCDCE9")
    }
    
    class var grayColor: UIColor {
        return UIColor.hex(hexString: "5B5C73")
    }
    
    class var redColor: UIColor {
        return UIColor.hex(hexString: "FF0606")
    }
    
    class var moneyColor: UIColor {
        return UIColor.hex(hexString: "FF5300")
    }
    
    class var faceSheetColor: UIColor {
        return UIColor.hex(hexString: "101010")
    }
    
    class var lightThemeColor: UIColor {
        return UIColor.hex(hexString: "E7E9FD")
    }
    
    class var inputBoxTextColor: UIColor {
        return UIColor.hex(hexString: "C0C1D7")
    }
}

extension UIColor {
    convenience init(r:UInt32 ,g:UInt32 , b:UInt32 , a:CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: a)
    }
    
    class var random: UIColor {
        return UIColor(r: arc4random_uniform(256),
                       g: arc4random_uniform(256),
                       b: arc4random_uniform(256))
    }
    
    func image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func hex(hexString: String) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cString.count < 6 { return UIColor.black }
        
        let index = cString.index(cString.endIndex, offsetBy: -6)
        let subString = cString[index...]
        if cString.hasPrefix("0X") { cString = String(subString) }
        if cString.hasPrefix("#") { cString = String(subString) }
        
        if cString.count != 6 { return UIColor.black }
        
        var range: NSRange = NSMakeRange(0, 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(r: r, g: g, b: b)
    }
}


