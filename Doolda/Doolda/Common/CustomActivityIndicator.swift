//
//  CustomActivityIndicator.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/13.
//

import Combine
import UIKit

import SnapKit

final class CustomActivityIndicator: UIView {
    
    // MARK: - Subviews
    
    private lazy var activityIndicatorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = .hedgehog
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .dooldaSublabel
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    private lazy var subTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .dooldaSublabel
        return label
    }()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    convenience init(subTitle: String?) {
        self.init(frame: .zero)
        self.subTitle.text = subTitle
        configureUI()
        bindUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.backgroundColor = .dooldaActivityIndicatorBackground
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.activityIndicatorImage)
        self.activityIndicatorImage.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.activityIndicator.snp.top).offset(-10)
        }
        
        self.addSubview(self.subTitle)
        self.subTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.activityIndicator.snp.bottom).offset(10)
        }
    }
    
    func bindUI() {
        self.publisher(for: UITapGestureRecognizer())
            .sink { _ in }
            .store(in: &self.cancellables)
        
        self.publisher(for: UIPanGestureRecognizer())
            .sink { _ in }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Public Methods
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}
