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
    
    static let photoPickerFrameCellIdentifier = "photoPickerFrameCellIdentifier"
    
    // MARK: - Subviews
    
    private lazy var frameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.shadowColor = UIColor.lightGray.cgColor
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowOpacity = 0.3
        // FIXME : scaleAspectFit으로 생기는 이미지 여백의 그림자 처리를 dynamic shadow방식말고 사용할 수 있도록 개선
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var displayName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dovemayo", size: 22)
        label.textColor = .dooldaLabel
        return label
    }()
    
    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.frameImageView,
            self.displayName
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
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
        self.addSubview(self.cellStackView)
        self.cellStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.frameImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.displayName.snp.makeConstraints { make in
            make.top.equalTo(self.frameImageView.snp.bottom).priority(.low)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    // MARK: - Public Methods
    
    func fill(_ photo: CIImage, _ displayName: String) {
        self.frameImageView.image = UIImage(ciImage: photo)
        self.displayName.text = displayName
    }
}
