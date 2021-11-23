//
//  StickerPickerCollectionViewFooter.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import UIKit

import SnapKit

class StickerPickerCollectionViewFooter: UICollectionReusableView {

    // MARK: - Static Properties

    static let identifier = "StickerPickerCollectionViewFooter"

    // MARK: - Subviews

    private lazy var title: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
        return label
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(self.title)
        self.title.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func configureStickerPackTilte(with stickerPackName: String) {
        self.title.text = stickerPackName
    }

}
