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
    
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .dooldaSubLabel
        indicator.hidesWhenStopped = false
        return indicator
    }()
    
    private lazy var subTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .dooldaSubLabel
        return label
    }()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    convenience init(subTitle: String?, loadingImage: UIImage? = .hedgehog) {
        self.init(frame: .zero)
        self.subTitle.text = subTitle
        self.loadingImageView.image = loadingImage
        configureUI()
        configureFont()
        bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.backgroundColor = .dooldaActivityIndicatorBackground
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.loadingImageView)
        self.loadingImageView.snp.makeConstraints { make in
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
    
    private func configureFont() {
        self.subTitle.font = .systemFont(ofSize: 20)
    }
    
    private func bindUI() {
        self.publisher(for: UITapGestureRecognizer())
            .sink { _ in }
            .store(in: &self.cancellables)
        
        self.publisher(for: UIPanGestureRecognizer())
            .sink { _ in }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
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
