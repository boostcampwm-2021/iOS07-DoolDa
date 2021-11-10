//
//  PhotoPickerCollectionViewCell.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import UIKit

import SnapKit

class PhotoPickerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let photoPickerCellIdentifier = "photoPickerCellIdentifier"
    
    // MARK: - Subviews
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var orderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        label.text = "1"
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        label.backgroundColor = .white.withAlphaComponent(0.4)
        label.layer.cornerRadius = self.orderLabelSize / 2
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: - Private Properties
    
    private let orderLabelSize = 28.0
    
    // MARK: - Initializer
    
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
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.orderLabel)
        self.orderLabel.snp.makeConstraints { make in
            make.width.height.equalTo(self.orderLabelSize)
            make.trailing.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
        }
        
        self.imageView.backgroundColor = .red
    }
    
    // MARK: - Public Methods
    
    func select(order: Int) {
        // FIXME : cell select animation
    }
    
    func deselect() {
        // FIXME : cell deselect animation
    }
}
