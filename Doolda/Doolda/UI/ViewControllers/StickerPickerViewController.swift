//
//  StickerPickerViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/15.
//

import UIKit

class StickerPickerViewController: BottomSheetViewController {

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.detent = .medium
    }

}
