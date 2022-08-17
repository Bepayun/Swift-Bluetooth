//
//  BluetoothPrintMode.swift
//  BluetoothDemo
//
//  Created by apple on 2022/3/18.
//

import UIKit

class BluetoothPrintMode: NSObject {
    
    static let shared = BluetoothPrintMode()
    
    public let regex = try! NSRegularExpression(pattern: "[\\u4E00-\\u9FEF]|[\\uFF01]|[\\uFF0C-\\uFF0E]|[\\uFF1A-\\uFF1B]|[\\uFF1F]|[\\uFF08-\\uFF09]|[\\u3001-\\u3002]|[\\u3010-\\u3011]|[\\u201C-\\u201D]|[\\u2013-\\u2014]|[\\u2018-\\u2019]|[\\u2026]|[\\u3008-\\u300F]|[\\u3014-\\u3015]")
    
    // MARK: - PDF to image
    private func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
    
    // MARK: - PDF打印模式
    func getPrintPDFMode(pathFileName: String?, printerType: String?) -> Data {
        let datas = NSMutableData()
        let path = Bundle.main.path(forResource: pathFileName, ofType: "pdf")
        if let path = path {
            // 转位图 zlib
            let bitMap = BluetoothBitMap()
            
//            // 后期改成下载的PDF https://stackoverflow.com/questions/32604857/convert-pdf-to-uiimage
//            let ref = url as CFURL?
//            var pdf: CGPDFDocument? = nil
//            if let ref = ref {
//                pdf = CGPDFDocument(ref)
//            }
//            let page = pdf?.page(at: 1)
            
            // 逻辑: pdf->转图片
            let fileUrl: NSURL = NSURL(fileURLWithPath: path)
            var faceSheetImage: UIImage? = drawPDFfromURL(url: fileUrl as URL)
        
            /*
            // 逻辑: pdf->画个view把pdf放上去->view转图片
            let dataSource = PdfDataSource.create(withFileUrl: fileUrl as URL)
            let pdfView = PageView.init(dataSource: dataSource!, page: 1, scale: 2)

            pdfView.frame = CGRect(x: 0, y: 0, width: pdfView.frame.size.width, height: pdfView.frame.size.height)

//            let faceSheetImage: UIImage = bitMap.convertView(toImage: pdfView, width: 576, scale: 2.0)
            var faceSheetImage: UIImage? = pdfView.takeScreenshot(with: 2.0)
            pdfView.removeFromSuperview() */
//                self.saveImageToAlbum(image: bitMap.drawBigBWImage(faceSheetImage))

            if (printerType == "PDD") || (printerType == "PDD-520-") {
                let ggData = LzoBitMap.imageGG(bitMap.drawBigBWImage(faceSheetImage!), x: 0, y: 0, maxSize: 4096, thresh:128)
                faceSheetImage = nil
                let areaData = LzoBitMap.area(0, width: 576, height: 1040, qty: 1)

                datas.append(areaData)
                datas.append(ggData)

                let fData = LzoBitMap.form()
                let pData = LzoBitMap.print()

                datas.append(fData)
                datas.append(pData)
                
            } else if (printerType == "CS3") || (printerType == "CC3") {
                let writeData: Data = bitMap.drawBigBitmap(faceSheetImage!)

                datas.append(writeData)
                let mBytes:[UInt8] = [0x1D, 0x0C]
                let data:Data = Data(bytes: mBytes, count: mBytes.count)
                datas.append(data)
            }
        } else { return datas as Data }
        
        return datas as Data
    }
    
    
    // MARK: - 本地绘制面单打印模式
    func getFaceSheetMode(faceSheetView: FaceSheetView, printerType: String?) -> Data {
//        self.saveImageToAlbum(image: faceSheetImage)
        
        // MARK：- 转位图 zlib
        let bitMap = BluetoothBitMap()
//        var faceSheetImage: UIImage? = bitMap.convertView(toImage: faceSheetView, width: 576, scale: 1.0)
        
        var faceSheetImage: UIImage? = faceSheetView.takeScreenshot(with: 1.0)
        /*
        if (printerType == "M320") { // 目前佳博的还没对接
            let datas = NSMutableData()
            let writeData: Data = bitMap.drawBigBitmap(faceSheetImage)
            datas.append(writeData)
            
//                        let cpclStr = datas.reduce("") {$0 + String(format: "%02x", $1)}
//                        print("cpclStr === \(cpclStr)")
            // 46 45 45 44 20 32 30 30 0D 0A
            let mBytes:[UInt8] = [0x46, 0x45, 0x45, 0x44, 0x20, 0x32, 0x30, 0x30, 0x0D, 0x0A]
            let data:Data = Data(bytes: mBytes, count: mBytes.count)
            datas.append(data)
        
            return datas
        } */
        let datas = NSMutableData()
        if (printerType == "PDD") || (printerType == "PDD-520-") {
           
            let ggData = LzoBitMap.imageGG(bitMap.drawBigBWImage(faceSheetImage!), x: 0, y: 0, maxSize: 4096, thresh:128)
            faceSheetImage = nil
//            self.saveImageToAlbum(image: bitMap.drawBigBWImage(faceSheetImage))
            let areaData = LzoBitMap.area(0, width: 576, height: 1040, qty: 1)

            datas.append(areaData)
            datas.append(ggData)

            let fData = LzoBitMap.form()
            let pData = LzoBitMap.print()

            datas.append(fData)
            datas.append(pData)
            
        } else if (printerType == "CS3") || (printerType == "CC3") {
            // CS3 图片传输
            let writeData: Data = bitMap.drawBigBitmap(faceSheetImage!)
            datas.append(writeData)
            let mBytes:[UInt8] = [0x1D, 0x0C]
            let data:Data = Data(bytes: mBytes, count: mBytes.count)
            datas.append(data)
        }
        
        return datas as Data
    }

    // MARK: - 保存图片 测试代码 ---- {
    func saveImageToAlbum(image:UIImage) {
        print("图片--->\(image)")
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let e = error as NSError? {
            print(e)
        } else {
            ProgressHUD.showText("保存成功")
        }
    }
    // 测试代码 ---- }
    
    func writeToFile(data: Data, fileName: String) {
        // get path of directory
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        // create file url
        let fileurl =  directory.appendingPathComponent("\(fileName).txt")
        // if file exists then write data
        if FileManager.default.fileExists(atPath: fileurl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileurl.path) {
                // seekToEndOfFile, writes data at the last of file(appends not override)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
            else {
                print("Can't open file to write.")
            }
        }
        else {
            // if file does not exist write data for the first time
            do {
                try data.write(to: fileurl, options: .atomic)
            } catch {
                print("Unable to write in new file.")
            }
        }
    }
    
    // MARK: - CPCL打印 打印机面单数据处理
    // 详情地址拼接 address，区域，城市，省
    func CPCLAddressSplicing(response: PrintDataResponse) {
//        if Tool.isMex() {
//            // Street external number, internal number, Colony, City, State. References
//            let consigneeAddresArray: [String] = [(response.consigneeStreet), (response.consigneeExternalNo), (response.consigneeInternalNo), (response.consigneeSuburb), (response.consigneeCity), (response.consigneeProvince), (response.consigneeRemark)]
//            response.consigneeAddress = "\(consigneeAddresArray.filter { $0 != "" }.joined(separator: " "))"
//
//            let consignorArrressArray: [String] = [(response.consignorStreet), (response.consignorExternalNo), (response.consignorInternalNo), (response.consignorSuburb), (response.consignorCity), (response.consignorProvince), (response.consignorRemark)]
//            response.consignorAddress = "\(consignorArrressArray.filter { $0 != "" }.joined(separator: " "))"
//
//            response.consigneeCity = "\(response.consigneeRouteCode) | \(response.consigneeZipCode)" // route code | zip code
//
//        } else {
            let consigneeAddresArray: [String] = [(response.consigneeAddress), (response.consigneeArea), (response.consigneeCity), (response.consigneeProvince)]
            response.consigneeAddress = "\(consigneeAddresArray.filter { $0 != "" }.joined(separator: " "))"
            
            let consignorArrressArray: [String] = [(response.consignorAddress), (response.consignorArea), (response.consignorCity), (response.consignorProvince)]
            response.consignorAddress = "\(consignorArrressArray.filter { $0 != "" }.joined(separator: " "))"
//        }
        
        // 过滤"\n"并替换成 空格
        response.consigneeAddress = (response.consigneeAddress).contains("\n") ? response.consigneeAddress.replacingOccurrences(of: "\n", with: " ") : response.consigneeAddress
        
        response.consignorAddress = (response.consignorAddress).contains("\n") ? response.consignorAddress.replacingOccurrences(of: "\n", with: " ") : response.consignorAddress
    }
    
    public func CPCLPrintDataWriting(response: PrintDataResponse, printerType: String?) -> String {
        // TODO: 考虑 printerType "" 的情况
        // 1、根据printerType配对连接的打印机型号
        // 2、通过templateCode配对打印机对应的面单模板
        var str = templates[printerType ?? ""]?[response.templateCode]
        
        // consigneeContact consignorContact 字符大于16 包含16 截取前16个
        // TODO：阿拉伯语目前也是按16个字符截取的
        response.consigneeContact = CPCLGetCharacterLength(string: response.consigneeContact)
        response.consignorContact = CPCLGetCharacterLength(string: response.consignorContact)

        // 将response的所有属性名全部走一遍替换
        Mirror(reflecting: response).children.compactMap { $0.label }.forEach{ str = str!.replacingOccurrences(of: "{{\($0)}}", with: "\(response.value(forKey: $0) ?? $0)") }
        
        if (printerType == "CS3") {
            // 阿拉伯语言字体变化
            ["consigneeCity", "consigneeContact", "consigneeAddress", "consignorContact", "consignorAddress", "sku"].forEach({
                if ("\(response.value(forKey: $0))").findChineseCharacters == .contain {
                    str = str!.replacingOccurrences(of: "{{middleFont_\($0)}}", with: "\(CS3_font)")
                    str = str!.replacingOccurrences(of: "{{middleFontSize_\($0)}}", with: "\(CS3_fontSize)")
                    str = str!.replacingOccurrences(of: "{{YCoordinate_\($0)}}", with: "\(CS3_YCoordinate)")
                    
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFont_\($0)}}", with: "\(CS3_consigneeCityFont)")
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFontSize_\($0)}}", with: "\(CS3_consigneeCityFontSize)")
                    
                } else if ("\(response.value(forKey: $0))").isArabic {
                    str = str!.replacingOccurrences(of: "{{middleFont_\($0)}}", with: "\(CS3_font_Arabic)")
                    str = str!.replacingOccurrences(of: "{{middleFontSize_\($0)}}", with: "\(CS3_fontSize_Arabic)")
                    str = str!.replacingOccurrences(of: "{{YCoordinate_\($0)}}", with: "\(CS3_YCoordinate_Arabic)")
                    
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFont_\($0)}}", with: "\(CS3_consigneeCityFont_Arabic)")
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFontSize_\($0)}}", with: "\(CS3_consigneeCityFontSize_Arabic)")
                } else {
                    str = str!.replacingOccurrences(of: "{{middleFont_\($0)}}", with: "\(CS3_font)")
                    str = str!.replacingOccurrences(of: "{{middleFontSize_\($0)}}", with: "\(CS3_fontSize)")
                    str = str!.replacingOccurrences(of: "{{YCoordinate_\($0)}}", with: "\(CS3_YCoordinate)")
                    
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFont_\($0)}}", with: "\(CS3_consigneeCityFont)")
                    str = str!.replacingOccurrences(of: "{{consigneeCityMiddleFontSize_\($0)}}", with: "\(CS3_consigneeCityFontSize)")
                }
            })
        }
        
        // 需要拆分的属性额外处理
        [("consignorAddress", address_line_count, address_char_count), ("consigneeAddress", address_line_count, address_char_count), ("sku", sku_line_count, sku_char_count), ("consigneeContact", name_line_count, name_char_count), ("consignorContact", name_line_count, name_char_count)].forEach {
            let value: String = "\(response.value(forKey: "\($0.0)") ?? $0)"
            var left: Int = 0
            for part in 1...$0.1 {
                var valuePart = ""
                
                var right: Int
                if left < value.count {
                    var characterLength: Int = 0
                    right = left
                    while right < value.count {
                        let s = value.subString(from: right, to: right)
                        if let matches = regex.firstMatch(in: s, range: NSRange(location: 0, length: 1)) {
                            characterLength += 2 // 汉字及中文符号
                        } else {
                            characterLength += 1
                        }
                        if characterLength <= $0.2 {
                            right = right + 1
                        } else {
                            break
                        }
                    }
                    let leftIndex = value.index(value.startIndex, offsetBy: left)
                    let rightIndex = value.index(value.startIndex, offsetBy: right)
                    valuePart = String(value[leftIndex..<rightIndex])
                    left = right
                }
                str = str?.replacingOccurrences(of: "{{\($0.0)\(part)}}", with: valuePart)
            }
        }
        // 一个文件一个文件打印
        if str != nil {
            return str!
        }
        return ""
    }
    
    // 中文 字符串长度＋2 [含中文符号]；非中文 字符串长度＋1
    func CPCLGetCharacterLength(string: String) -> String {
        var characterLength: Int = 0
        var mutableString = string
        var result: String = ""
        for s in string {
            if let matches = regex.firstMatch(in: String(s), range: NSRange(location: 0, length: 1)) {
                characterLength += 2
            } else {
                characterLength += 1
            }
            if characterLength <= 16 {
                // 这个字符加进去
                result = ("\(result)\(s)")
            } else {
                break
            }
        }
        mutableString = result
        
        return mutableString
    }
}
