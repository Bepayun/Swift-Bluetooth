//
//  UIFont+Speedy.swift
//  AppSpeedy
//
//  Created by apple on 2022/4/1.
//

import UIKit
extension UIFont {
    public class func sc_regular(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    public class func sc_semibold(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    public class func sc_medium(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    public class func sc_bold(size:CGFloat)->UIFont{
        return UIFont(name: "PingFangSC-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    public class func bold(size:CGFloat)->UIFont{
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
}

extension UIFont {
    
    class var bold12: UIFont {
        return UIFont.systemFont(ofSize: 12.0)
    }
    
    class var bold14: UIFont {
        return UIFont.systemFont(ofSize: 14.0, weight: .bold)
    }
    
    class var bold15: UIFont {
        return UIFont.systemFont(ofSize: 15.0, weight: .bold)
    }
    
    class var bold16: UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .bold)
    }
    
    class var bold18: UIFont {
        return UIFont.systemFont(ofSize: 18.0, weight: .bold)
    }
    
    class var bold20: UIFont {
        return UIFont.systemFont(ofSize: 20.0, weight: .bold)
    }
    
    class var bold28: UIFont {
        return UIFont.systemFont(ofSize: 28.0, weight: .bold)
    }
    
    class var medium14: UIFont {
        return UIFont.systemFont(ofSize: 14.0, weight: .medium)
    }
    
    class var theme14: UIFont {
        return UIFont.systemFont(ofSize: 14.0)
    }
    
    class var theme12: UIFont {
        return UIFont.systemFont(ofSize: 12.0)
    }
    
    class var theme10: UIFont {
        return UIFont.systemFont(ofSize: 10.0)
    }
    
    class var theme16: UIFont {
        return UIFont.systemFont(ofSize: 16.0)
    }
    
    class var theme15: UIFont {
        return UIFont.systemFont(ofSize: 15.0)
    }
    
    class var theme13: UIFont {
        return UIFont.systemFont(ofSize: 13.0)
    }
    
    class var theme18: UIFont {
        return UIFont.systemFont(ofSize: 18.0)
    }
    
    class var theme20: UIFont {
        return UIFont.systemFont(ofSize: 20.0)
    }
}
