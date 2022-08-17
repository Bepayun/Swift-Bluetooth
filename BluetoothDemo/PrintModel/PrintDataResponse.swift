//
//  PrintDataResponse.swift
//  BluetoothDemo
//
//  Created by apple on 2021/10/21.
//

import Foundation

//(printDate: "2022-04-13 15:23:41", waybillNo: "6041222938808", consignorCountry: "MEX", consignorProvince: "Ciudad Province", consignorCity: "Ciudad City", consignorArea: "", consignorSuburb: "可以", consignorZipCode: "99899", consignorStreet: "阿德", consignorExternalNo: "哦哦哦", consignorInternalNo: "", consignorRemark: "", consignorRouteCode: "", consignorAddress: "阿德,哦哦哦,可以", consignorContact: "测试", consignorPhone: "+525555512345", consigneeCountry: "MEX", consigneeProvince: "Ciudad Province", consigneeCity: "Ciudad City", consigneeArea: "", consigneeSuburb: "我们", consigneeZipCode: "99899", consigneeStreet: "ww", consigneeExternalNo: "问一下", consigneeInternalNo: "", consigneeRemark: "", consigneeRouteCode: "", consigneeAddress: "www,问一下,我们", consigneeContact: "测试www", consigneePhone: "+525555554321", collectingMoney: "88", freightAmount: "15", originalFreightAmount: "", returnFreightAmount: "", codAndFreightAmount: "15", sku: "file", currency: "MXN", csTel: "9899248234", stationName: "CPS2", templateCode: "label_freight_prepaid_ppd")

class PrintDataResponse: NSObject, Codable {
    // 继承NSObject并用@objc定义属性，以启用KVC访问
    @objc var printDate: String = "2022-04-13 15:23:41"
    @objc var waybillNo: String = "6041222938808"
    @objc var consignorCountry: String = "MEX"
    @objc var consignorProvince: String = "Ciudad Province"
    @objc var consignorCity: String = "Ciudad City"
    @objc var consignorArea: String = ""
    @objc var consignorSuburb: String = "可以"
    @objc var consignorZipCode: String = "99899"
    @objc var consignorStreet: String = "阿德"
    @objc var consignorExternalNo: String = "哦哦哦"
    @objc var consignorInternalNo: String = ""
    @objc var consignorRemark: String = ""
    @objc var consignorRouteCode: String = ""
    @objc var consignorAddress: String = "阿德,哦哦哦,可以"
    @objc var consignorContact: String = "测试"
    @objc var consignorPhone: String = "+525555512345"
    @objc var consigneeCountry: String = "MEX"
    @objc var consigneeProvince: String = "Ciudad Province"
    @objc var consigneeCity: String = "Ciudad City"
    @objc var consigneeArea: String = ""
    @objc var consigneeSuburb: String = "我们"
    @objc var consigneeZipCode: String = "99899"
    @objc var consigneeStreet: String = "www"
    @objc var consigneeExternalNo: String = "问一下"
    @objc var consigneeInternalNo: String = ""
    @objc var consigneeRemark: String = ""
    @objc var consigneeRouteCode: String = ""
    @objc var consigneeAddress: String = "www,问一下,我们"
    @objc var consigneeContact: String = "测试www"
    @objc var consigneePhone: String = "+525555554321"
    @objc var collectingMoney: String = "88"
    @objc var freightAmount: String = "15"
    @objc var originalFreightAmount: String = ""
    @objc var returnFreightAmount: String = ""
    @objc var codAndFreightAmount: String = "15"
    @objc var sku: String = "file"
    @objc var currency: String = "MXN"
    @objc var csTel: String = "9899248234"
    @objc var stationName: String = "CPS2"
    @objc var templateCode: String = "label_freight_prepaid_ppd"
}

//class PrintDataResponse: NSObject, Codable {
//    // 继承NSObject并用@objc定义属性，以启用KVC访问
//    @objc var printDate: String?
//    @objc var waybillNo: String?
//    @objc var consignorCountry: String?
//    @objc var consignorProvince: String?
//    @objc var consignorCity: String?
//    @objc var consignorArea: String?
//    @objc var consignorSuburb: String?
//    @objc var consignorZipCode: String?
//    @objc var consignorStreet: String?
//    @objc var consignorExternalNo: String?
//    @objc var consignorInternalNo: String?
//    @objc var consignorRemark: String?
//    @objc var consignorRouteCode: String?
//    @objc var consignorAddress: String?
//    @objc var consignorContact: String?
//    @objc var consignorPhone: String?
//    @objc var consigneeCountry: String?
//    @objc var consigneeProvince: String?
//    @objc var consigneeCity: String?
//    @objc var consigneeArea: String?
//    @objc var consigneeSuburb: String?
//    @objc var consigneeZipCode: String?
//    @objc var consigneeStreet: String?
//    @objc var consigneeExternalNo: String?
//    @objc var consigneeInternalNo: String?
//    @objc var consigneeRemark: String?
//    @objc var consigneeRouteCode: String?
//    @objc var consigneeAddress: String?
//    @objc var consigneeContact: String?
//    @objc var consigneePhone: String?
//    @objc var collectingMoney: String?
//    @objc var freightAmount: String?
//    @objc var originalFreightAmount: String?
//    @objc var returnFreightAmount: String?
//    @objc var codAndFreightAmount: String?
//    @objc var sku: String?
//    @objc var currency: String?
//    @objc var csTel: String?
//    @objc var stationName: String?
//    @objc var templateCode: String?
//}
