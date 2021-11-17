//
//  UnpackedStickerCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import UIKit

import SnapKit

class UnpackedStickerCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let identifier = "UnpackedStickerCell"

    // MARK: - Subviews

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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

    func configure(with sticker: URL) {
        guard let image = try? UIImage(data: Data(contentsOf: sticker)) else { return }
        self.imageView.image = image
    }

    private func configureUI() {
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
