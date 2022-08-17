//
//  PrinterHelper.swift
//  
//
//  Created by apple on 2021/8/2.
//

import Foundation
import UIKit

class PrinterHelper {
    // 这些数字都是10进制的 ASCII码
    let ESC:UInt8   = 27    // 换码
    let FS:UInt8    = 28    // 文本分隔符
    let GS:UInt8    = 29    // 组分隔符
    let DLE:UInt8   = 16    // 数据连接换码
    let EOT:UInt8   = 4     // 传输结束
    let ENQ:UInt8   = 5     // 询问字符
    let SP:UInt8    = 32    // 空格
    let HT:UInt8    = 9     // 横向列表
    let LF:UInt8    = 10    // 打印并换行（水平定位）
    let ER:UInt8    = 13    // 归位键
    let FF:UInt8    = 12    // 走纸控制（打印并回到标准模式（在页模式下） ）

    
    var maxLine: Int = 4
    
    let LEFT_LENGTH: Int = 10
    let RIGHT_LENGTH: Int = 10
    let LEFT_BYTE_SIZE: Int = 10
    
    
    /** 打印机样式*/
    enum PrinterStyle: NSInteger {
        case kDefaultStyle
        case kCustomStyle
    }
    /** 文字对齐方式 */
    enum PrinterTextAlignment: NSInteger {
        case kTextAlignmentLeft = 0x00
        case kTextAlignmentCenter = 0x01
        case kTextAlignmentRight = 0x02
    }
    /** 字号 */
    enum PrinterFontSize: NSInteger {
        case kFontSizeTitleSmalle = 0x00
        case kFontSizeTitleMiddle = 0x11
        case kFontSizeTitleBig = 0x22
    }

    // 初始化打印机
    func clear() -> Data {
        return Data.init([ESC, 64])
    }
    // 打印空格
    func printBlank(number: Int) -> Data {
        var foo: [UInt8] = []
        for _ in 0..<number { foo.append(SP)}
        return Data.init(foo)
    }
    // 换行
    func nextLine(number: Int) -> Data {
        var foo: [UInt8] = []
        for _ in 0..<number {foo.append(LF)}
        return Data.init(foo)
    }
    // 绘制下划线
    func printUnderline() -> Data {
        var foo: [UInt8] = []
        foo.append(ESC)
        foo.append(45)
        foo.append(1) // 一个像素
        return Data.init(foo)
    }
    // 取消绘制下划线
    func cancelUnderline() -> Data {
        var foo: [UInt8] = []
        foo.append(ESC)
        foo.append(45)
        foo.append(0)
        return Data.init(foo)
    }
    // 加粗文字
    func boldOn() -> Data {
        var foo: [UInt8] = []
        foo.append(ESC)
        foo.append(69)
        foo.append(0xF)
        return Data.init(foo)
    }
    // 取消加粗文字
    func boldOff() -> Data {
        var foo: [UInt8] = []
        foo.append(ESC)
        foo.append(69)
        foo.append(0)
        return Data.init(foo)
    }
    // 左对齐
    func alignLeft() -> Data {
        return Data.init([ESC,97,0])
    }
    // 居中对齐
    func alignCenter() -> Data {
        return Data.init([ESC,97,1])
    }
    // 右对齐
    func alignRight() -> Data {
        return Data.init([ESC,97,2])
    }
    // 水平方向向右移动col列
    func alignRight(col: UInt8) -> Data {
        var foo: [UInt8] = []
        foo.append(ESC)
        foo.append(68)
        foo.append(col)
        foo.append(0)
        return Data.init(foo)
    }
    // 字体变大为标准的n倍
    func fontSize(font: Int8) -> Data {
        var realSize: UInt8 = 0
        switch font {
        case 1:
            realSize = 0
        case 2:
            realSize = 17
        case 3:
            realSize = 34
        case 4:
            realSize = 51
        case 5:
            realSize = 68
        case 6:
            realSize = 85
        case 7:
            realSize = 102
        case 8:
            realSize = 119
        default:
            break
        }
        var foo: [UInt8] = []
        foo.append(29)
        foo.append(33)
        foo.append(realSize)
        return Data.init(foo)
    }
    // 进纸并全部切割
    func feedPaperCutAll() -> Data {
        var foo: [UInt8] = []
        foo.append(GS)
        foo.append(86)
        foo.append(65)
        foo.append(0)
        return Data.init(foo)
    }
    // 进纸并切割(左边留一点不切)
    func feedPaperCutPartial() -> Data {
        var foo: [UInt8] = []
        foo.append(GS)
        foo.append(86)
        foo.append(66)
        foo.append(0)
        return Data.init(foo)
    }
    // 设置纸张间距为默认
    func mergerPaper() -> Data {
        return Data.init([ESC,109])
    }
    // 添加文字，不换行
    func setTitle(text: String) -> Data {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        ///这里一定要GB_18030_2000，测试过用utf-系列是乱码，踩坑了。
        let data = text.data(using: String.Encoding(rawValue: enc), allowLossyConversion: false)
        if data != nil{
            return data!
        }
        return Data()
    }
    
    let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
    
    // text 内容 value 右侧内容 左侧列 支持的最大显示 超过四字自动换行
    func setText(text: String, value: String, maxChar: Int) -> Data {
        let data = text.data(using: String.Encoding(rawValue: enc))! as NSData
        
        if (data.length > maxChar) {
            let lines = data.length / maxChar
            let remainder = data.length % maxChar
            let tempData: NSMutableData = NSMutableData.init()
            for i in 0..<lines {
                let temp = (data.subdata(with: NSMakeRange(i*maxChar, maxChar)) as NSData)
                tempData.append(temp.bytes, length: temp.length)
                if i == 0 {
                    let data = setOffsetText(value: value)
                    tempData.append(data.bytes, length: data.length)
                }
                let line = nextLine(number: 1) as NSData
                tempData.append(line.bytes, length: line.length)
            }
            if remainder != 0 { // 余数不0
                let temp = data.subdata(with: NSMakeRange(lines*maxChar, remainder)) as NSData
                tempData.append(temp.bytes, length: temp.length)
            }
            return tempData as Data
        }
        let rightTextData = setOffsetText(value: value)
        let mutData = NSMutableData.init(data: data as Data)
        mutData.append(rightTextData.bytes, length: rightTextData.length)
        return mutData as Data
    }

    // 字符串根据一行最大值maxTextCount分成数组
    func printStrArrWithText(text: String, maxTextCount: Int) -> [String] {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        
        var textArr: [String] = []
        let textData = setTitle(text: text) as NSData
        let textLength = textData.length
        if textLength > maxTextCount {
            // 需要几行
            let lines = textLength / maxTextCount
            // 余数
            let remainder = textLength % maxTextCount
            // 设置最大支持7行
            for i in 0..<lines {
                let temp = textData.subdata(with: NSMakeRange(i*maxTextCount, maxTextCount))
                let str = String(data: temp, encoding: String.Encoding(rawValue: enc))
                
                if str == nil {
                    let temp = textData.subdata(with: NSMakeRange(i*maxTextCount-1, maxTextCount))
                    let str = String(data: temp, encoding: String.Encoding(rawValue: enc))
                    if str != nil {
                        textArr.append(str!)
                    }
                } else {
                    textArr.append(str!)
                }
            }
            // 记录的值 小于当前行数 并且 有余数 就 lines+1 否则 记录lines
            if maxLine < lines && remainder != 0 {
                maxLine = lines + 1
            } else if maxLine < lines && remainder == 0 {
                maxLine = lines
            }
            if remainder != 0 {
                let temp = textData.subdata(with: NSMakeRange(lines*maxTextCount, remainder))
                let str = String(data: temp, encoding: String.Encoding(rawValue: enc))
                textArr.append(str!)
            }
        } else { // 文本没超过限制
            if maxLine == 0 { maxLine = 1 }
            textArr.append(text)
        }
        if textArr.count < 5 { // 最多支持5
            for _ in 0..<5-textArr.count {
                textArr.append("")
            }
        }
        
        return textArr
    }
    
    /**
     * 设置偏移文字
     *
     * @param value 右侧内容
     */
    func setOffsetText(value: String) -> NSData {
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 22.0)] //设置字体大小
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        // 获取字符串的frame
        let rect:CGRect = value.boundingRect(with: CGSize.init(width: 320.0, height: 999.9), options: option, attributes: attributes, context: nil)
        let valueWidth: Int = Int(rect.size.width)
        let preNum = (UserDefaults.standard.value(forKey: "printerNum") ?? 0) as! Int
        let offset = (preNum == 0 ? 384 : 566) - valueWidth
        let remainder = offset % 256
        let consult = offset / 256;
        var foo:[UInt8] = [0x1B, 0x24]
        foo.append(UInt8(remainder))
        foo.append(UInt8(consult))
        let data = Data.init(_: foo) as NSData
        let mutData = NSMutableData.init()
        mutData.append(data.bytes, length: data.length)
        let titleData = setTitle(text: value) as NSData
        mutData.append(titleData.bytes, length: titleData.length)
        return mutData as NSData
    }

    /**
     * 打印三列
     *
     * @param leftText 左侧文字
     * @param middleText 中间文字
     * @param rightText 右侧文字
     * @return
     */
    func printThreeData(leftText: String, middleText: String, rightText: String) -> String {
        var strText = ""
        
        let leftTextLenght = (setTitle(text: leftText) as NSData).length
        let middleTextLenght = (setTitle(text: middleText) as NSData).length
        let rightTextLenght = (setTitle(text: rightText) as NSData).length
        
        strText = strText + leftText
        
        // 计算左侧文字和中间文字的空格长度
        let marginBetweenLeftAndMiddle = LEFT_LENGTH - leftTextLenght - middleTextLenght/2
        for _ in 0..<marginBetweenLeftAndMiddle {
            strText = strText + " "
        }
        
        strText = strText + middleText
        // 计算右侧文字和中间文字的空格长度
        let marginBetweenMiddleAndRight = RIGHT_LENGTH - middleTextLenght/2 - rightTextLenght
        for _ in 0..<(marginBetweenMiddleAndRight) {
            strText = strText + " "
        }
        strText = strText + rightText
        return strText
    }
    
    // 打印两列
    func printTwoData(leftText: String, rightText: String) -> Data {
        var strText = ""
        let leftTextLength = (setTitle(text: leftText) as NSData).length
        let rightTextLength = (setTitle(text: rightText) as NSData).length
        strText = strText + leftText
        
        // 计算文字中间的空格
        let marginBetweenMiddleAndRight = LEFT_BYTE_SIZE - leftTextLength - rightTextLength
        for _ in 0..<marginBetweenMiddleAndRight {
            strText = strText + " "
        }
        strText = strText + rightText
        
        let data = NSMutableData()
        let lineData = nextLine(number: 1)
        data.append(setTitle(text: strText))
        data.append(lineData)
        return data as Data
    }
    
    // 两列 右侧文本自动换行 maxChar 个字符
    func setRightTextAutoLine(left: String, right: String, maxText: Int) -> Data {
        // 存放打印的数据（data）
        let printerData: NSMutableData = NSMutableData.init()
        
        let valueCount = right.count
        if valueCount > maxText {
            // 需要几行
            let lines = valueCount / maxText
            // 余数
            let remainder = valueCount % maxText
            for i in 0..<lines {
                let index1 = right.index(right.startIndex, offsetBy: i*maxText)
                let index2 = right.index(right.startIndex, offsetBy: i*maxText + maxText)
                let sub1 = right[index1..<index2]
                print(sub1)
                if i == 0 {
                    let tempData = printTwoData(leftText: left, rightText: String(sub1))
                    printerData.append(tempData)
                } else {
                    let tempData = printTwoData(leftText: "", rightText: String(sub1))
                    printerData.append(tempData)
                }
            }
            if remainder != 0 {
                let index1 = right.index(right.startIndex, offsetBy: lines*maxText)
                let index2 = right.index(right.startIndex, offsetBy: lines*maxText + remainder)
                let sub1 = right[index1..<index2]
                print(sub1)
                let tempData = printTwoData(leftText: "", rightText: String(sub1))
                printerData.append(tempData)
            }
        } else {
            let tempData = printTwoData(leftText: left, rightText: right)
            printerData.append(tempData)
        }
        
        let lineData = nextLine(number: 1)
        printerData.append(lineData)
        return printerData as Data
    }
    
    // text 内容。value 右侧内容 左侧列 支持的最大显示 超过四字自动换行
    // 两列 左侧文本自动换行
    func setLeftTextLine(text: String, value: String, maxChar: Int) -> Data {
        let data = text.data(using: String.Encoding(rawValue: enc))! as NSData
        if (data.length > maxChar) {
        let lines = data.length / maxChar
        let remainder = data.length % maxChar
        let tempData: NSMutableData = NSMutableData.init()
        for i in 0..<lines {
            let temp = (data.subdata(with: NSMakeRange(i*maxChar, maxChar)) as NSData)
            tempData.append(temp.bytes, length: temp.length)
            if i == 0 {
                let data = setOffsetText(value: value)
                tempData.append(data.bytes, length: data.length)
            }
            let line = nextLine(number: 1) as NSData
            tempData.append(line.bytes, length: line.length)
        }
        if remainder != 0 { // 余数不0
            let temp = data.subdata(with: NSMakeRange(lines*maxChar, remainder)) as NSData
            tempData.append(temp.bytes, length: temp.length)
        }
        return tempData as Data
    }
    let rightTextData = setOffsetText(value: value)
    let mutData = NSMutableData.init(data: data as Data)
    mutData.append(rightTextData.bytes, length: rightTextData.length)
    return mutData as Data
    }
}
