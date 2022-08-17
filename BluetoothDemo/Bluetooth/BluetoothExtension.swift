//
//  Extension.swift
//  ScannerView
//
//  Created by apple on 2021/7/22.
//

import Foundation

// consignorAddress&consigneeAddress 36个字符换行
let address_char_count: Int = 36
// consignorAddress&consigneeAddress 行数
let address_line_count: Int = 4
// sku 23个字符换行
let sku_char_count: Int = 23
// sku 行数
let sku_line_count: Int = 3
// name 16个字符进行切割，超出的不显示
let name_char_count: Int = 16
// name 行数
let name_line_count: Int = 1

// CS3 阿拉伯语的字号 55 0
let CS3_font_Arabic: Int = 55
let CS3_fontSize_Arabic: Int = 0
// CS3 非阿拉伯语的字号 333 2 [之前是0 16]
let CS3_font: Int = 333
let CS3_fontSize: Int = 2

// CS3 阿拉伯语的字号 55 0
let CS3_consigneeCityFont_Arabic: Int = 55
let CS3_consigneeCityFontSize_Arabic: Int = 0
// CS3 非阿拉伯语的字号 0 16
let CS3_consigneeCityFont: Int = 0
let CS3_consigneeCityFontSize: Int = 16

// CS3 阿拉伯语的字号 consigneeCity 165
let CS3_YCoordinate_Arabic: Int = 165
// CS3 非阿拉伯语的字号 consigneeCity 155
let CS3_YCoordinate: Int = 155

// 字符串中是否含有阿拉伯语
extension String {
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
}

extension Bool {
    var int: Int { self ? 1 : 0 }
}

extension Data {
    var hex: String { map{ String(format: "%02x", $0) }.joined() }
}


