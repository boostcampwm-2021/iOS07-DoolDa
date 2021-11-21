//
//  DooldaButton.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import UIKit

class DooldaButton: UIButton {
    override var isEnabled: Bool {
        didSet { self.alpha = self.isEnabled ? 1.0 : 0.5 }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
}
