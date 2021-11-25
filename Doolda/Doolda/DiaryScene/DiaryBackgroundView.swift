//
//  DiaryBackgroundView.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/22.
//

import UIKit

class DiaryBackgroundView: UIView {
    
    // MARK: - Subviews
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .dooldaLabel
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.imageView, self.titleLabel, self.subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        get { return self.imageView.image }
        set { self.imageView.image = newValue }
    }
    
    var title: String? {
        get { return self.titleLabel.text }
        set { self.titleLabel.text = newValue }
    }
    
    var titleFont: UIFont {
        get { return self.titleLabel.font }
        set { self.titleLabel.font = newValue }
    }
    
    var subtitle: String? {
        get { return self.subtitleLabel.text }
        set { self.subtitleLabel.text = newValue }
    }
    
    var subtitleFont: UIFont {
        get { return self.subtitleLabel.font }
        set { self.subtitleLabel.font = newValue }
    }
    
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
        self.addSubview(self.titleStackView)
        self.titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
        }
    }
}
