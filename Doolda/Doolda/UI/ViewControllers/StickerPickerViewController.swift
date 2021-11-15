//
//  StickerPickerViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/15.
//

import UIKit

import SnapKit

class StickerPickerViewController: BottomSheetViewController {

    // MARK: - Subviews

    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.text = "스티커 추가"
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.sizeToFit()
        return button
    }()

    private lazy var topStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.bottomSheetTitle,
                self.closeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.detent = .medium
        self.body.backgroundColor = .dooldaBackground

        self.body.addSubview(self.topStack)
        self.topStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

}
