//
//  PackedStickerCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import UIKit

import SnapKit

class PackedStickerCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let identifier = "PackedStickerCell"

    // MARK: - Subviews

    private lazy var bodyView: UIView = {
        let bodyView = UIView()
        bodyView.backgroundColor = UIColor(cgColor: CGColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.7))
        return bodyView
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(self.bodyView)
        self.bodyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }

        let dummyStickers = [
            UIImage(named: "dochi_0"),
            UIImage(named: "dochi_1")
        ]
        dummyStickers.forEach { stickers in
            let imageView = UIImageView()
            imageView.image = stickers
            self.bodyView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.25)
                make.height.equalTo(imageView.snp.width)
            }
        }

    }

}
