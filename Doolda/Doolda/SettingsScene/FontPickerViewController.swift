//
//  FontPickerViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/23.
//

import Combine
import UIKit

import SnapKit

class FontPickerViewController: BottomSheetViewController {

    // MARK: - Subviews

    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.text = "폰트 설정"
        label.textAlignment = .center
        return label
    }()

    private lazy var applyButton: UIButton = {
        let button = DooldaButton()
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.setTitle("적용", for: .normal)
        return button
    }()

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.detent = .medium
        self.body.backgroundColor = .dooldaBackground

        self.body.addSubview(self.bottomSheetTitle)
        self.body.snp.makeConstraints { make in
            make.top.equalTo(self.body).offset(16)
            make.leading.trailing.equalTo(self.body)
        }

        self.body.addSubview(self.applyButton)
        self.applyButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    private func configureFont() {
        self.bottomSheetTitle.font = .systemFont(ofSize: 16)
    }

}
