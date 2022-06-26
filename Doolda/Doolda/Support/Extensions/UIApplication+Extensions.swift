//
//  UIApplication+Extensions.swift
//  Doolda
//
//  Created by USER on 2022/06/26.
//

import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        self.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .compactMap { $0 as? UIWindowScene }.first?.windows
            .filter {$0.isKeyWindow}.first
    }
}
