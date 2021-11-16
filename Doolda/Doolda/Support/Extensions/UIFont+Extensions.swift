//
//  UIFont+Extensions.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import UIKit

extension UIFont {
    static var isOverrided: Bool = false
    static var defaultFontFamily: String = "dovemayo"
    
    class func overrideInitialize() {
        guard self == UIFont.self , !isOverrided else { return }

        isOverrided = true

        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }

        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }

        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
    }
    
    @objc fileprivate class func mySystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize)
    }
    
    @objc fileprivate class func myBoldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize, withTraits: .traitBold)
    }
    
    @objc fileprivate class func myItalicSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        return myDefaultFont(ofSize: fontSize, withTraits: .traitItalic)
    }
    
    fileprivate class func myDefaultFont(ofSize fontSize: CGFloat, withTraits traits: UIFontDescriptor.SymbolicTraits = []) -> UIFont {
        guard let descriptor = UIFontDescriptor(name: defaultFontFamily, size: fontSize).withSymbolicTraits(traits) else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}
