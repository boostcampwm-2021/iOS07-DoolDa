//
//  PhotoFrameCollectionViewCell.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import UIKit

import SnapKit

class PhotoFrameCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let photoPickerFrameCellId = "photoPickerFrameCellId"
    
    // MARK: - Subviews
    
    let frameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        self.addSubview(self.frameImageView)
        self.frameImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func fill(_ photoFrame: PhotoFrameType) {
        guard let photoFrame = photoFrame.rawValue else {
            return self.frameImageView.image = nil
        }

        self.frameImageView.image = UIImage(ciImage: photoFrame.baseImage)
    }
}
