//
//  AuthenticationViewController.swift
//  Doolda
//
//  Created by Dozzing on 2022/03/30.
//

//
//  AuthenticationViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/12/28.
//

import AuthenticationServices
import Combine
import UIKit

import FirebaseAuth
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

    private var viewModel: AuthenticationViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(viewModel: AuthenticationViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // FIXME: - Coordinator 구현 전 임시 코드
        self.configureUI()
        self.bindUI()
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
        self.viewModel.noncePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nonce in
                self?.performSignIn(with: nonce)
            }
            .store(in: &self.cancellables)

        self.appleLoginButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.appleLoginButtonDidTap()
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Private Methods

    private func performSignIn(with nonce: String) {
        guard let request = self.createAppleIDRequest(with: nonce) else { return }
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func createAppleIDRequest(with nonce: String) -> ASAuthorizationAppleIDRequest? {
        if nonce.isEmpty { return nil }
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        return request
    }

}

extension AuthenticationViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.viewModel.signIn(authorization: authorization)
    }
}

extension AuthenticationViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
