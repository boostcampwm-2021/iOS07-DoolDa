//
//  UIView+Extensions.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import UIKit

extension UIView {
    func publisher(for gestureRecognizer: UIGestureRecognizer) -> UIGestureRecognizer.InteractionPublisher {
        return UIGestureRecognizer.InteractionPublisher(gestureRecognizer: gestureRecognizer, view: self)
    }
}
