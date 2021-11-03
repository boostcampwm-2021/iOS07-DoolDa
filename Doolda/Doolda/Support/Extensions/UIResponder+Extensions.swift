//
//  UIResponder+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import Combine
import UIKit

extension UIResponder {
    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            .map {
                guard let initialFrame = $0.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue,
                      let resultingFrame = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return 0.0 }
                let initialHeight = initialFrame.cgRectValue.height
                let resultingHeight = resultingFrame.cgRectValue.height
                return initialHeight < resultingHeight ? resultingHeight : 0.0
            }
            .eraseToAnyPublisher()
    }
}
