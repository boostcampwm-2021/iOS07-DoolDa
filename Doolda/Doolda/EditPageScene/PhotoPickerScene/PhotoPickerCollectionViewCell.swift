//
//  PhotoPickerCollectionViewCell.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import Photos
import UIKit

import SnapKit

class PhotoPickerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let photoPickerCellIdentifier = "photoPickerCellIdentifier"
    
    // MARK: - Subviews
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var orderedSelectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        label.backgroundColor = .white.withAlphaComponent(0.4)
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Private Properties
    
    private var requestImageId: PHImageRequestID?
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Lifecycle Methods
    
    override func layoutSubviews() {
        self.orderedSelectionLabel.layer.cornerRadius = self.orderedSelectionLabel.frame.width / 2
    }
    
    override func prepareForReuse() {
        if let requestImageId = requestImageId {
            PHImageManager.default().cancelImageRequest(requestImageId)
        }
        self.imageView.image = .hedgehogWriting
        self.activityIndicator.startAnimating()
        self.deselect()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.layer.borderColor = UIColor.dooldaBackground?.cgColor
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.orderedSelectionLabel)
        self.orderedSelectionLabel.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
        }
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.layoutIfNeeded()
    }
    
    // MARK: - Public Methods
    
    func display(_ asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = .opportunistic
        imageRequestOptions.isNetworkAccessAllowed = true
        
        self.requestImageId = PHImageManager.default().requestImage(
            for: asset,
            targetSize: self.bounds.size,
            contentMode: .aspectFill,
            options: imageRequestOptions
        ) { image, _ in
            self.imageView.image = image
            self.activityIndicator.stopAnimating()
        }
    }
    
    func select(order: Int) {
        self.orderedSelectionLabel.text = "\(order)"
        self.layer.borderWidth = 1
        
        self.orderedSelectionLabel.layer.borderColor = .dooldaBackground
        self.orderedSelectionLabel.backgroundColor = .dooldaHighlighted
    }
    
    func deselect() {
        self.orderedSelectionLabel.text = nil
        self.layer.borderWidth = 0
        
        self.orderedSelectionLabel.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        self.orderedSelectionLabel.backgroundColor = .white.withAlphaComponent(0.4)
    }
}
