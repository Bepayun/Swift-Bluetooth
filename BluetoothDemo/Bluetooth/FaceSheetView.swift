//
//  FaceSheetView.swift
//  BluetoothDemo
//
//  Created by apple on 2021/11/17.
//  451*642

import UIKit

class FaceSheetView: UIView {
    
    var printData: PrintDataResponse? {
        didSet {
            guard let printData = printData else { return }
            
            // 打印日期
            printDate.text = "Print Time:\(printData.printDate)"
            
            // 条形码【右上】
            barcodeImgView.image = generateBarcode(from: printData.waybillNo , size: CGSize(width:297, height: 80))
            // 运单号
            waybillNo.text = printData.waybillNo
            
            // ================ consignee 收件人 ================
            // 收件人
            consigneeContactLab.text = printData.consigneeContact
            
            // 收件人手机号
            consigneePhoneLab.text = printData.consigneePhone
            
            // 站名 stationName
            stationNameLab.text = printData.stationName
            
            // ================ consignor 寄件人 ================
            // 寄件人
            consignorContactLab.text = printData.consignorContact
            
            // 寄件人手机号
            consignorPhoneLab.text = printData.consignorPhone
            
            addressSplicing(response: printData)
            
            // sku
            skuLab.text = printData.sku
            
            // 条形码【底部】
            barcodeImgViewTwo.image = generateBarcode(from: printData.waybillNo , size: CGSize(width: 427, height: 100))
            // 运单号【底部】
            waybillNoTwo.text = "\(printData.waybillNo)"
            
            // CS Call:{{csTel}}
            csCallLab.text = "CS Call:\(printData.csTel)"
            
            /*
             label_freight_collect_cod                 COD & Delivery Charge
             label_freight_collect_ppd                 Delivery Charge
             label_freight_prepaid_cod                 COD
             label_freight_prepaid_ppd
             label_return_shipping_address_original    Delivery Charge
             label_return_shipping_address             Delivery Charge
             */
            paymentLab.text = "Payment:Freight Collect"
            let currencyString = "(\(printData.currency))"
            
            if (printData.templateCode).contains("label_freight_collect_cod") {
                // 模板1
                // cod amount
                codAmountLab.isHidden = false
                codAmountLab.text = "COD Amount:\(printData.collectingMoney)"
                // freight amount
                freightAmountLab.isHidden = false
                freightAmountLab.text = "Freight:\(printData.freightAmount)"
                
                // Freight
                freightLab.isHidden = false
                freightLab.text = "COD & Delivery Charge"
                
                codAmountAndCurrency(codAmount: "\(printData.codAndFreightAmount)", currency: currencyString)
                
            } else if (printData.templateCode).contains("label_freight_collect_ppd") {
                // 模板2
                // Freight
                freightLab.isHidden = false
                freightLab.text = "Delivery Charge"
                
                codAmountAndCurrency(codAmount: "\(printData.freightAmount)", currency: currencyString)
                
            } else if (printData.templateCode).contains("label_freight_prepaid_cod") {
                // 模板3
                paymentLab.text = "Payment:Freight Prepaid"
                // Freight
                freightLab.isHidden = false
                freightLab.text = "COD"
                
                codAmountAndCurrency(codAmount: "\(printData.collectingMoney)", currency: currencyString)
                
            } else if (printData.templateCode).contains("label_freight_prepaid_ppd") {
                // 模板4
                paymentLab.text = "Payment:Freight Prepaid"
                
                codAmountAndCurrency(codAmount: "0", currency: currencyString)
                
            } else if (printData.templateCode).contains("label_return_shipping_address_original") {
                // 模板5
                // Freight
                freightLab.isHidden = false
                freightLab.text = "Delivery Charge"
                
                codAmountAndCurrency(codAmount: "\(printData.freightAmount)", currency: currencyString)
                
                // return
                returnLab.isHidden = false
                
                // returnFreightAmount
                returnFreightAmountLab.isHidden = false
                returnFreightAmountLab.text = "Return Delivery Charge:\(printData.returnFreightAmount)"
                
                // originalFreightAmount
                originalFreightAmountLab.isHidden = false
                originalFreightAmountLab.text = "Original Delivery Charge:\(printData.originalFreightAmount)"
                
            } else if (printData.templateCode).contains("label_return_shipping_address") {
                
                // 模板6
                // Freight
                freightLab.isHidden = false
                freightLab.text = "Delivery Charge"
                
                codAmountAndCurrency(codAmount: "\(printData.freightAmount)", currency: currencyString)
                
                // return
                returnLab.isHidden = false
            }
            
            // TODO: lynn test data ---- {
            /*// Freight
            freightLab.isHidden = false
            freightLab.text = "Delivery Charge"
            
            // return
            returnLab.isHidden = false
            
            // returnFreightAmount
            returnFreightAmountLab.isHidden = false
            returnFreightAmountLab.text = "Return Delivery Charge:\(printData.returnFreightAmount ?? "")"
            
            // originalFreightAmount
            originalFreightAmountLab.isHidden = false
            originalFreightAmountLab.text = "Original Delivery Charge:\(printData.originalFreightAmount ?? "")"
            
            // cod amount
            codAmountLab.isHidden = false
            codAmountLab.text = "COD Amount:\(printData.collectingMoney ?? "")"
            // freight amount
            freightAmountLab.isHidden = false
            freightAmountLab.text = "Freight:\(printData.freightAmount ?? "")"
            codAmountAndCurrency(codAmount: "0", currency: currencyString) */
            // lynn test data ---- }
        }
    }
    
    // 详情地址拼接 address，区域，城市，省
    private func addressSplicing(response: PrintDataResponse) {
        
//        if Tool.isMex() {
//            // Street external number, internal number, Colony, City, State. References
//            let consigneeAddresArray: [String] = [(response.consigneeStreet ?? ""), (response.consigneeExternalNo ?? ""), (response.consigneeInternalNo ?? ""), (response.consigneeSuburb ?? ""), (response.consigneeCity ?? "") , (response.consigneeProvince ?? ""), (response.consigneeRemark ?? "")]
//            response.consigneeAddress = "\(consigneeAddresArray.filter { $0 != "" }.joined(separator: " "))"
//
//            let consignorArrressArray: [String] = [(response.consignorStreet ?? ""), (response.consignorExternalNo ?? ""), (response.consignorInternalNo ?? ""), (response.consignorSuburb ?? ""), (response.consignorCity ?? ""), (response.consignorProvince ?? ""), (response.consignorRemark ?? "")]
//            response.consignorAddress = "\(consignorArrressArray.filter { $0 != "" }.joined(separator: " "))"
//
//            response.consigneeCity = "\(response.consigneeRouteCode ?? "") | \(response.consigneeZipCode ?? "")" // route code | zip code
//
//        } else {
        let consigneeAddresArray: [String] = [(response.consigneeAddress), (response.consigneeArea), (response.consigneeCity), (response.consigneeProvince)]
            
            response.consigneeAddress = "\(consigneeAddresArray.filter { $0 != "" }.compactMap { $0.isArabic ?  "\u{202B}\($0)\u{202C}" : $0}.joined(separator: "\u{200E} \u{200E}"))"
            
        let consignorArrressArray: [String] = [(response.consignorAddress), (response.consignorArea), (response.consignorCity), (response.consignorProvince)]
            
            // \u{202B} RTL \u{202C}
            // 逗号本身不是一个强方向性的字符，所以两个强LTR字符\u{200E}，夹住逗号，保证被LTR排版
            response.consignorAddress = "\(consignorArrressArray.filter { $0 != "" }.compactMap { $0.isArabic ?  "\u{202B}\($0)\u{202C}" : $0}.joined(separator: "\u{200E} \u{200E}"))"
//        }
        
        // 过滤"\n"并替换成 空格
        response.consigneeAddress = (response.consigneeAddress).contains("\n") ? response.consigneeAddress.replacingOccurrences(of: "\n", with: " ") : response.consigneeAddress
        
        response.consignorAddress = (response.consignorAddress).contains("\n") ? response.consignorAddress.replacingOccurrences(of: "\n", with: " ") : response.consignorAddress
        
        // 收件人地址
        consigneeAddressLab.text = response.consigneeAddress
        
        // 寄件人地址 6111621207534
        consignorAddressLab.text = response.consignorAddress
        
        // 收件人城市
        consigneeCityLab.text = response.consigneeCity
    }
    
    // MARK: - cod amount and currency
    private func codAmountAndCurrency(codAmount: String, currency: String) {
        let accountAttStr = NSMutableAttributedString.init(string: codAmount)
        let currencyAttStr = NSAttributedString.init(string: currency , attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.theme20])
        accountAttStr.append(currencyAttStr)
        currencyLab.attributedText = accountAttStr
    }
    // MARK: - 生成条形码
    func generateBarcode(from string: String, size: CGSize) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            guard let newImage = filter.outputImage else { return nil }
            
            let scaleX:CGFloat = size.width / newImage.extent.width
            let scaleY:CGFloat = size.height / newImage.extent.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
            
        }
        
        return nil
    }
    
    // 顶部虚线
    private lazy var topDottedLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 左虚线
    private lazy var leftDottedLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 右虚线
    private lazy var rightDottedLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 底部虚线
    private lazy var bottomDottedLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 打印日期
    private lazy var printDate: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .right, numberLines: 1)
        return o
    }()
    
    // 打印日期虚线
    private lazy var printDateLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // logo 图片
    private lazy var logoImgview: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "printlogo")
        o.contentMode = .scaleAspectFill
        return o
    }()
    
    // 条形码【右上】
    private lazy var barcodeImgView: UIImageView = {
        let o = UIImageView()
        o.contentMode = .center
        return o
    }()
    
    // 运单号
    private lazy var waybillNo: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // 运单号底部虚线
    private lazy var waybillNoLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.layer.masksToBounds = true
        o.contentMode = .scaleAspectFill
        return o
    }()
    
    // ================ consignee 收件人 ================
    private lazy var toLab: UILabel = {
        let o = UILabel(text: "To", textColor: .faceSheetColor, textFont: .bold20, textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // 收件人城市
    private lazy var consigneeCityLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: UIFont.systemFont(ofSize: 26, weight: .bold), textAlignment: .left, numberLines: 0)
        o.lineBreakMode = .byCharWrapping
        return o
    }()
    
    // 收件人城市左虚线
    private lazy var cityLeftLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 收件人城市底部虚线
    private lazy var cityBottomLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 收件人
    private lazy var consigneeContactLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        o.lineBreakMode = .byCharWrapping
        return o
    }()
    
    // 收件人手机号
    private lazy var consigneePhoneLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // 收件人地址
    private lazy var consigneeAddressLab: UILabel = {
        // UIFont.systemFont(ofSize: 16, weight: .ultraLight)
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, numberLines: 0)
        o.textAlignment = .natural
        o.lineBreakMode = .byCharWrapping
        return o
    }()
    
    // 站名 stationName
    private lazy var stationNameLab: UILabel = {
        let o = UILabel(text: "", textColor: UIColor.hex(hexString: "8E9093"), textFont: UIFont.systemFont(ofSize: 72.0, weight: .bold), textAlignment: .right, numberLines: 1)
        o.alpha = 0.5
        return o
    }()
    
    // 收件人底部虚线
    private lazy var consigneeBottomLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // ================ consignor 寄件人 ================
    private lazy var senderLab: UILabel = {
        let o = UILabel(text: "Sender", textColor: .faceSheetColor, textFont: .bold20, textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // 寄件人
    private lazy var consignorContactLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        o.lineBreakMode = .byCharWrapping
        return o
    }()
    
    // 寄件人手机号
    private lazy var consignorPhoneLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // 寄件人地址
    private lazy var consignorAddressLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, numberLines: 0)
        o.textAlignment = .natural
        o.lineBreakMode = .byCharWrapping
        return o
    }()
    
    // 寄件人底部虚线
    private lazy var consignorBottomLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // Payment:Freight Prepaid
    private lazy var paymentLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // Payment右边虚线
    private lazy var paymentRightLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // Express Order
    private lazy var expressOrderLab: UILabel = {
        let o = UILabel(text: "Express Order", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // Express Order右边虚线
    private lazy var expressOrderRightLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // Signature:
    private lazy var signatureLab: UILabel = {
        let o = UILabel(text: "Signature:", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // Signature底部虚线
    private lazy var signatureBottomLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // Goods Name:
    private lazy var goodsNameLab: UILabel = {
        let o = UILabel(text: "Goods Name:", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // sku
    private lazy var skuLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 0)
        return o
    }()
    
    // sku右边虚线
    private lazy var skuLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "h_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // currency
    private lazy var currencyLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: UIFont.systemFont(ofSize: 40, weight: .bold), textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // 底部虚线
    private lazy var currencyDottedLine: UIImageView = {
        let o = UIImageView()
        o.image = UIImage(named: "v_dotted_line")
        o.contentMode = .scaleAspectFill
        o.layer.masksToBounds = true
        return o
    }()
    
    // 条形码【底部】
    private lazy var barcodeImgViewTwo: UIImageView = {
        let o = UIImageView()
        o.contentMode = .center
        return o
    }()
    
    // 运单号【底部】
    private lazy var waybillNoTwo: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .center, numberLines: 1)
        return o
    }()
    
    // 网站
    private lazy var websiteLab: UILabel = {
        let o = UILabel(text: "Website:www.imile.com", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        return o
    }()
    
    // CS Call:{{csTel}}
    private lazy var csCallLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .right, numberLines: 1)
        return o
    }()
    
    // 区别
    // cod amount
    private lazy var codAmountLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme20, textAlignment: .left, numberLines: 1)
        o.isHidden = true
        return o
    }()
    
    // freight amount
    private lazy var freightAmountLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        o.isHidden = true
        return o
    }()
    
    // Freight
    private lazy var freightLab: UILabel = {
        let o = UILabel(text: "", textColor: .white, textFont: .bold16, textAlignment: .center, numberLines: 1)
        o.backgroundColor = .black
        o.isHidden = true
        return o
    }()
    
    // return
    private lazy var returnLab: UILabel = {
        let o = UILabel(text: "Return", textColor: .white, textFont: UIFont.systemFont(ofSize: 26, weight: .bold), textAlignment: .center, numberLines: 1)
        o.backgroundColor = .black
        o.isHidden = true
        return o
    }()
    
    // returnFreightAmount
    private lazy var returnFreightAmountLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        o.isHidden = true
        return o
    }()
    
    // originalFreightAmount
    private lazy var originalFreightAmountLab: UILabel = {
        let o = UILabel(text: "", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        o.isHidden = true
        return o
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        let lineHeight = 3
        // 顶部虚线
        addSubview(topDottedLine)
        topDottedLine.snp.makeConstraints {
            $0.top.equalTo(space)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(lineHeight)
        }
        
        // 左虚线
        addSubview(leftDottedLine)
        leftDottedLine.snp.makeConstraints {
            $0.top.equalTo(topDottedLine.snp.bottom)
            $0.left.equalTo(20)
            $0.bottom.equalTo(-space)
            $0.width.equalTo(lineHeight)
        }
        
        // 右虚线
        addSubview(rightDottedLine)
        rightDottedLine.snp.makeConstraints {
            $0.top.equalTo(topDottedLine.snp.bottom)
            $0.right.equalTo(-20)
            $0.bottom.equalTo(-space)
            $0.width.equalTo(lineHeight)
        }
        
        // 底部虚线
        addSubview(bottomDottedLine)
        bottomDottedLine.snp.makeConstraints {
            $0.bottom.equalTo(-space)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(lineHeight)
        }
        
        // 条形码【右上】
        addSubview(barcodeImgView)
        
        // 打印日期
        addSubview(printDate)
        printDate.snp.makeConstraints {
            $0.top.equalTo(topDottedLine.snp.bottom).offset(8)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-12)
            $0.height.equalTo(18)
            $0.width.equalTo(400)
        }
        
        #if DEBUG
        let pictureLab = UILabel(text: "Picture", textColor: .faceSheetColor, textFont: .theme16, textAlignment: .left, numberLines: 1)
        addSubview(pictureLab)
        pictureLab.snp.makeConstraints {
            $0.top.equalTo(topDottedLine.snp.bottom).offset(8)
            $0.left.equalTo(leftDottedLine.snp.right).offset(12)
            $0.height.equalTo(18)
            $0.width.equalTo(80)
        }
        #endif
        
        // 打印日期虚线
        addSubview(printDateLine)
        printDateLine.snp.makeConstraints {
            $0.top.equalTo(printDate.snp.bottom).offset(8)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.height.equalTo(lineHeight)
        }
        
        // logo 图片
        addSubview(logoImgview)
        logoImgview.snp.makeConstraints {
            $0.top.equalTo(printDateLine.snp.bottom).offset(10)
            $0.left.equalTo(leftDottedLine.snp.right).offset(25)
            $0.size.equalTo(CGSize(width: 180, height: 60))
        }
        
        barcodeImgView.snp.makeConstraints {
            $0.top.equalTo(printDateLine.snp.bottom).offset(10)
            $0.left.equalTo(logoImgview.snp.right).offset(2)
            $0.height.equalTo(60)
            $0.width.equalTo(297)//ScreenWidth/2
        }
        
        // 运单号
        addSubview(waybillNo)
        waybillNo.snp.makeConstraints {
            $0.centerX.equalTo(barcodeImgView.snp.centerX)
            $0.top.equalTo(barcodeImgView.snp.bottom).offset(10)
            $0.width.equalTo(barcodeImgView.snp.width)
        }
        
        // 运单号底部虚线
        addSubview(waybillNoLine)
        waybillNoLine.snp.makeConstraints {
            $0.top.equalTo(waybillNo.snp.bottom).offset(10)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.width.equalTo(lineHeight)
        }
        
        // ================ consignee 收件人 ================
        // 收件人城市
        addSubview(consigneeCityLab)
        consigneeCityLab.snp.makeConstraints {
            $0.top.equalTo(waybillNoLine.snp.bottom)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-3)
            $0.width.equalTo(200)
            $0.height.lessThanOrEqualTo(75)
        }
        
        // 收件人城市左虚线
        addSubview(cityLeftLine)
        cityLeftLine.snp.makeConstraints {
            $0.top.equalTo(waybillNoLine.snp.bottom)
            $0.right.equalTo(consigneeCityLab.snp.left).offset(-5)
            $0.height.equalTo(consigneeCityLab.snp.height)
            $0.width.equalTo(lineHeight)
        }
        
        // 收件人城市底部虚线
        addSubview(cityBottomLine)
        cityBottomLine.snp.makeConstraints {
            $0.top.equalTo(consigneeCityLab.snp.bottom)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.width.equalTo(consigneeCityLab.snp.width)
            $0.height.equalTo(lineHeight)
        }
        
        addSubview(toLab)
        toLab.snp.makeConstraints {
            $0.top.equalTo(waybillNoLine.snp.bottom).offset(27)
            $0.left.equalTo(leftDottedLine.snp.right).offset(5)
            $0.width.equalTo(73)
            $0.height.equalTo(31)
        }
        
        // 收件人
        addSubview(consigneeContactLab)
        consigneeContactLab.snp.makeConstraints {
            $0.top.equalTo(waybillNoLine.snp.bottom).offset(14)
            $0.left.equalTo(toLab.snp.right).offset(10)
            $0.width.equalTo(225)
            $0.height.equalTo(24)
        }
        
        // 收件人手机号
        addSubview(consigneePhoneLab)
        consigneePhoneLab.snp.makeConstraints {
            $0.top.equalTo(consigneeContactLab.snp.bottom).offset(8)
            $0.left.equalTo(toLab.snp.right).offset(10)
            $0.right.equalTo(cityLeftLine.snp.left).offset(-2)
            $0.height.equalTo(24)
        }
        
        // 收件人地址
        addSubview(consigneeAddressLab)
        consigneeAddressLab.snp.makeConstraints {
            $0.top.equalTo(consigneePhoneLab.snp.bottom).offset(8)
            $0.leading.equalTo(toLab.snp.trailing).offset(10)
            $0.trailing.equalTo(rightDottedLine.snp.leading).offset(-5)
            $0.height.equalTo(80)
        }
        
        // 收件人底部虚线
        addSubview(consigneeBottomLine)
        consigneeBottomLine.snp.makeConstraints {
            $0.top.equalTo(consigneeAddressLab.snp.bottom).offset(5)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.height.equalTo(lineHeight)
        }
        
        // 站名 stationName
        addSubview(stationNameLab)
        stationNameLab.snp.makeConstraints {
            $0.centerY.equalTo(consigneeBottomLine.snp.centerY)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-27)
        }
        
        // ================ consignor 寄件人 ================
        addSubview(senderLab)
        senderLab.snp.makeConstraints {
            $0.top.equalTo(consigneeBottomLine.snp.bottom).offset(27)
            $0.left.equalTo(leftDottedLine.snp.right).offset(5)
            $0.width.equalTo(73)
            $0.height.equalTo(31)
        }
        
        // 寄件人
        addSubview(consignorContactLab)
        consignorContactLab.snp.makeConstraints {
            $0.top.equalTo(consigneeBottomLine.snp.bottom).offset(14)
            $0.left.equalTo(senderLab.snp.right).offset(10)
            $0.width.equalTo(225)
            $0.height.equalTo(24)
        }
        
        // 寄件人手机号
        addSubview(consignorPhoneLab)
        consignorPhoneLab.snp.makeConstraints {
            $0.top.equalTo(consignorContactLab.snp.bottom).offset(8)
            $0.left.equalTo(senderLab.snp.right).offset(10)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-space)
            $0.height.equalTo(24)
        }
        
        // 寄件人地址
        addSubview(consignorAddressLab)
        consignorAddressLab.snp.makeConstraints {
            $0.top.equalTo(consignorPhoneLab.snp.bottom).offset(8)
            $0.leading.equalTo(senderLab.snp.trailing).offset(10)
            $0.trailing.equalTo(rightDottedLine.snp.leading).offset(-5)
            $0.height.equalTo(80)
        }
        
        // 寄件人底部虚线
        addSubview(consignorBottomLine)
        consignorBottomLine.snp.makeConstraints {
            $0.top.equalTo(consignorAddressLab.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.height.equalTo(lineHeight)
        }
        
        // Payment右边虚线
        addSubview(paymentRightLine)
        paymentRightLine.snp.makeConstraints {
            $0.top.equalTo(consignorBottomLine.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right).offset(200)
            $0.height.equalTo(94)
            $0.width.equalTo(lineHeight)
        }
        
        // Payment:Freight Prepaid
        addSubview(paymentLab)
        paymentLab.snp.makeConstraints {
            $0.top.equalTo(consignorBottomLine.snp.bottom).offset(12)
            $0.left.equalTo(leftDottedLine.snp.right).offset(6)
            $0.right.equalTo(paymentRightLine.snp.left).offset(-3)
        }
        
        // cod amount
        addSubview(codAmountLab)
        codAmountLab.snp.makeConstraints {
            $0.top.equalTo(paymentLab.snp.bottom).offset(8)
            $0.left.equalTo(leftDottedLine.snp.right).offset(6)
            $0.right.equalTo(paymentRightLine.snp.left).offset(-3)
        }
        
        // freight amount
        addSubview(freightAmountLab)
        freightAmountLab.snp.makeConstraints {
            $0.top.equalTo(codAmountLab.snp.bottom).offset(8)
            $0.left.equalTo(leftDottedLine.snp.right).offset(6)
            $0.right.equalTo(paymentRightLine.snp.left).offset(-3)
        }
        
        // Express Order
        addSubview(expressOrderLab)
        expressOrderLab.snp.makeConstraints {
            $0.top.equalTo(consignorBottomLine.snp.bottom)
            $0.left.equalTo(paymentRightLine.snp.right)
            $0.width.equalTo(158)
            $0.height.equalTo(paymentRightLine.snp.height)
        }
        
        // Express Order右边虚线
        addSubview(expressOrderRightLine)
        expressOrderRightLine.snp.makeConstraints {
            $0.top.equalTo(consignorBottomLine.snp.bottom)
            $0.left.equalTo(expressOrderLab.snp.right)
            $0.height.equalTo(paymentRightLine.snp.height)
            $0.width.equalTo(lineHeight)
        }
        
        // Signature:
        addSubview(signatureLab)
        signatureLab.snp.makeConstraints {
            $0.top.equalTo(consignorBottomLine.snp.bottom).offset(3)
            $0.left.equalTo(expressOrderRightLine.snp.right).offset(4)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-3)
        }
        
        // Signature底部虚线
        addSubview(signatureBottomLine)
        signatureBottomLine.snp.makeConstraints {
            $0.top.equalTo(paymentRightLine.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.height.equalTo(lineHeight)
        }
        
        // sku右边虚线
        addSubview(skuLine)
        skuLine.snp.makeConstraints {
            $0.top.equalTo(signatureBottomLine.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right).offset(268)
            $0.width.equalTo(lineHeight)
            $0.height.equalTo(126)
        }
        
        
        // 底部虚线
        addSubview(currencyDottedLine)
        currencyDottedLine.snp.makeConstraints {
            $0.top.equalTo(skuLine.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.right.equalTo(rightDottedLine.snp.left)
            $0.height.equalTo(lineHeight)
        }
        
        // Goods Name:
        addSubview(goodsNameLab)
        goodsNameLab.snp.makeConstraints {
            $0.top.equalTo(signatureBottomLine.snp.bottom).offset(14)
            $0.left.equalTo(leftDottedLine.snp.right).offset(7)
            $0.right.equalTo(skuLine.snp.left).offset(-5)
        }
        
        // sku
        addSubview(skuLab)
        skuLab.snp.makeConstraints {
            $0.top.equalTo(goodsNameLab.snp.bottom).offset(8)
            $0.left.equalTo(leftDottedLine.snp.right).offset(7)
            $0.right.equalTo(skuLine.snp.left).offset(-5)
        }
        
        // Freight
        addSubview(freightLab)
        freightLab.snp.makeConstraints {
            $0.top.equalTo(signatureBottomLine.snp.bottom)
            $0.left.equalTo(skuLine.snp.right)
            $0.size.equalTo(CGSize(width: 210, height: 40))
        }
        
        // currency
        addSubview(currencyLab)
        currencyLab.snp.makeConstraints {
            $0.bottom.equalTo(currencyDottedLine.snp.top).offset(-12)
            $0.left.equalTo(skuLine.snp.right).offset(5)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-5)
        }
        
        // 条形码【底部】
        addSubview(barcodeImgViewTwo)
        
        // return
        addSubview(returnLab)
        returnLab.snp.makeConstraints {
            $0.top.equalTo(currencyDottedLine.snp.bottom)
            $0.left.equalTo(leftDottedLine.snp.right)
            $0.size.equalTo(CGSize(width: 134, height: 68))
        }
        
        // returnFreightAmount
        addSubview(returnFreightAmountLab)
        returnFreightAmountLab.snp.makeConstraints {
            $0.top.equalTo(currencyDottedLine.snp.bottom).offset(10)
            $0.left.equalTo(returnLab.snp.right).offset(5)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-5)
            $0.height.equalTo(20)
        }
        
        // originalFreightAmount
        addSubview(originalFreightAmountLab)
        originalFreightAmountLab.snp.makeConstraints {
            $0.top.equalTo(returnFreightAmountLab.snp.bottom).offset(8)
            $0.left.equalTo(returnLab.snp.right).offset(5)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-5)
            $0.height.equalTo(20)
        }
        
        barcodeImgViewTwo.snp.makeConstraints {
            $0.top.equalTo(returnLab.snp.bottom).offset(20)
            $0.left.equalTo(leftDottedLine.snp.right).offset(48)
            $0.size.equalTo(CGSize(width: 427, height: 88))
        }
        
        // 运单号【底部】
        addSubview(waybillNoTwo)
        waybillNoTwo.snp.makeConstraints {
            $0.top.equalTo(barcodeImgViewTwo.snp.bottom).offset(10)
            $0.left.equalTo(leftDottedLine.snp.right).offset(48)
            $0.size.equalTo(CGSize(width: 427, height: 20))
        }
        
        // 网站
        addSubview(websiteLab)
        websiteLab.snp.makeConstraints {
            $0.bottom.equalTo(bottomDottedLine.snp.top).offset(-8)
            $0.left.equalTo(leftDottedLine.snp.right).offset(10)
            $0.size.equalTo(CGSize(width: 200, height: 20))
        }
        
        // CS Call:{{csTel}}
        addSubview(csCallLab)
        csCallLab.snp.makeConstraints {
            $0.bottom.equalTo(bottomDottedLine.snp.top).offset(-8)
            $0.right.equalTo(rightDottedLine.snp.left).offset(-10)
            $0.size.equalTo(CGSize(width: 200, height: 20))
        }
    }
    
    deinit {
        print("FaceSheetView deinit")
    }
}


