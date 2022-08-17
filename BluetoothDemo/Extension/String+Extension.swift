//
//  String+Extension.swift
//  BluetoothDemo
//
//  Created by apple on 2022/4/13.
//

import Foundation
import UIKit


enum ChineseRange {
    case notFound, contain, all
}
extension String {
    var findChineseCharacters: ChineseRange {
        guard let a = self.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) else {
            return .notFound
        }
        var result: ChineseRange
        switch a {
        case nil:
            result = .notFound
        case self.startIndex..<self.endIndex:
            result = .all
        default:
            result = .contain
        }
        return result
    }
}

extension String {
    /// 截取到任意位置
    func subString(to: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: to)
        return String(self[..<index])
    }
    /// 从任意位置开始截取
    func subString(from: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: from)
        return String(self[index ..< endIndex])
    }
    /// 从任意位置开始截取到任意位置
    func subString(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
    //使用下标截取到任意位置
    subscript(to: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: to)
        return String(self[..<index])
    }
    //使用下标从任意位置开始截取到任意位置
    subscript(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
}

extension String {
    
    func isValidateEmail() -> Bool {
        if self.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    
    func isValidatePass() -> Bool {
        let mobile = "^(?!^\\d+$)(?!^[A-Za-z]+$)(?!^[^A-Za-z0-9]+$)(?!^.*[\\u4E00-\\u9FA5].*$)^\\S{8,}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: self) == true {
            return true
        }else {
            return false
        }
    }
}

extension String {
    func range(of subString: String) -> NSRange {
        let text = self as NSString
        return text.range(of: subString)
    }
}

/*
extension String {
    func local() -> String {
        var language: String = String(UserPrefs.locale.split(separator: "_")[0])
        if language == "zh" {
            language = "zh-Hans"
        }
        if let bundlePath = Bundle.main.path(forResource: language, ofType: "lproj") {
            if let bundle = Bundle(path: bundlePath) {
                return bundle.localizedString(forKey: self, value: self, table: nil)
            }
        }
        return self
    }
}
 */

/// Date formatter
extension String {
    
    func toDateTime(oldFormat: String = "yyyy-MM-dd HH:mm:ss", newFormat: String = "MM-dd") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oldFormat
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = newFormat
        return dateFormatter.string(for: date)
    }
}

extension String {
    /// 富文本设置 字体大小 行间距 字间距
    func attributedString(font: UIFont, textColor: UIColor, lineSpaceing: CGFloat, wordSpaceing: CGFloat) -> NSAttributedString {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceing
        let attributes = [
            NSAttributedString.Key.font             : font,
            NSAttributedString.Key.foregroundColor  : textColor,
            NSAttributedString.Key.paragraphStyle   : style,
            NSAttributedString.Key.kern             : wordSpaceing]
        
        as [NSAttributedString.Key : Any]
        let attrStr = NSMutableAttributedString.init(string: self, attributes: attributes)
        
        // 设置某一范围样式
        return attrStr
    }
}

extension String {
    func textWidth(font:UIFont,height:CGFloat) -> CGFloat{
        let width = self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: NSStringDrawingOptions(rawValue:  NSStringDrawingOptions.usesFontLeading.rawValue |    NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue), attributes: [NSAttributedString.Key.font:font], context: nil).size.width;
        return width;
    }
    
    func textHeight(fontSize: UIFont, width: CGFloat) -> CGFloat {
        return self.boundingRect(with:CGSize(width: width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font:fontSize], context:nil).size.height
    }
}

