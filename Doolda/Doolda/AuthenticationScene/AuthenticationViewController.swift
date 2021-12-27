//
//  AuthenticationViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/12/28.
//

import Combine
import UIKit

import AuthenticationServices
import SnapKit

class AuthenticationViewController: UIViewController {

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "둘다"
        label.font = UIFont(name: FontType.dovemayo.name, size: 72)
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "서비스 이용을 위해 회원가입이 필요해요."
        label.font = UIFont(name: FontType.dovemayo.name, size: 18)
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var appleLoginButton = ASAuthorizationAppleIDButton()

    private lazy var leftHedgehogImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage.hedgehogWriting
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var rightHedgehogImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage.hedgehogWriting?.withHorizontallyFlippedOrientation()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground

        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(self.view.frame.height * 0.20)
        }

        self.view.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(30)
        }

        self.view.addSubview(self.appleLoginButton)
        self.appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        self.view.addSubview(self.leftHedgehogImage)
        self.leftHedgehogImage.snp.makeConstraints { make in
            make.height.equalTo(360)
            make.trailing.equalTo(self.view.snp.centerX).offset(-32)
            make.bottom.equalToSuperview()
        }

        self.view.addSubview(self.rightHedgehogImage)
        self.rightHedgehogImage.snp.makeConstraints { make in
            make.height.equalTo(360)
            make.leading.equalTo(self.view.snp.centerX).offset(32)
            make.bottom.equalToSuperview()
        }
    }

    private func bindUI() {
        self.appleLoginButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                
            }
            .store(in: &self.cancellables)
    }

}
