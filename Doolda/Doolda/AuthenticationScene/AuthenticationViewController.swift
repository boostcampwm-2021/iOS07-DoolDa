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

    private lazy var emailTextField: DooldaTextField = {
        var textField = DooldaTextField()
        textField.titleText = "이메일"
        textField.placeholder = "이메일을 입력해주세요"
        textField.textContentType = .emailAddress
        return textField
    }()
    
    private lazy var passwordTextField: DooldaTextField = {
        var textField = DooldaTextField()
        textField.titleText = "비밀번호"
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var createAccountButton: UIButton = {
        var button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString = NSMutableAttributedString(string: "계정이 없으신가요?", attributes: attributes)
        button.setAttributedTitle(attributeString, for: .normal)
        button.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 16)
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(.dooldaLabel, for: .normal)
        return button
    }()
    
    private lazy var emailLoginButton: DooldaButton = {
        var button = DooldaButton()
        button.setTitle("로그인하기", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 16)
        button.isEnabled = false
        return button
    }()

    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.cornerRadius = 22
        return button
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
        self.configureUI()
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationItem.hidesBackButton = true

        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(130)
        }
        
        self.view.addSubview(self.emailTextField)
        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(60)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.passwordTextField)
        self.passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(18)
            make.leading.trailing.equalTo(self.emailTextField)
        }
        
        self.view.addSubview(self.createAccountButton)
        self.createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(8)
            make.leading.equalTo(self.passwordTextField)
        }

        self.view.addSubview(self.emailLoginButton)
        self.emailLoginButton.snp.makeConstraints { make in
            make.top.equalTo(self.createAccountButton.snp.bottom).offset(17)
            make.height.equalTo(44)
            make.leading.trailing.equalTo(self.emailTextField)
        }
        
        self.view.addSubview(self.appleLoginButton)
        self.appleLoginButton.snp.makeConstraints { make in
            make.top.equalTo(self.emailLoginButton.snp.bottom).offset(24)
            make.height.equalTo(48)
            make.leading.trailing.equalTo(self.emailTextField)
        }
    }

    private func bindUI() {
        self.createAccountButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.createAccountButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.viewModel.errorPublisher
            .sink { [weak self] error in
                guard let error = error else { return }
                self?.showLoginErrorAlert(error: error)
            }
            .store(in: &self.cancellables)
        
        self.appleLoginButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.appleLoginButtonDidTap(
                    authControllerDelegate: self,
                    authControllerPresentationProvider: self
                )
            }
            .store(in: &self.cancellables)
        
        self.emailLoginButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let email = self?.emailTextField.text,
                      let password = self?.passwordTextField.text else { return }
                self?.viewModel.emailLoginButtonDidTap(email: email, password: password)
            }
            .store(in: &self.cancellables)
        
        self.emailTextField.returnPublisher
            .sink { [weak self] _ in
                _ = self?.emailTextField.resignFirstResponder()
                _ = self?.passwordTextField.becomeFirstResponder()
            }
            .store(in: &self.cancellables)
        
        self.passwordTextField.returnPublisher
            .sink { [weak self] _ in
                _ = self?.passwordTextField.resignFirstResponder()
            }
            .store(in: &self.cancellables)
        
        Publishers
            .CombineLatest(self.emailTextField.textPublisher, self.passwordTextField.textPublisher)
            .sink { [weak self] email, password in
                guard !email.isEmpty && !password.isEmpty else {
                          self?.emailLoginButton.isEnabled = false
                          return
                      }
                self?.emailLoginButton.isEnabled = true
            }
            .store(in: &self.cancellables)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    private func showLoginErrorAlert(error: Error) {
        let alert = UIAlertController.defaultAlert(title: "로그인 실패", message: error.localizedDescription) { _ in }
        self.present(alert, animated: true)
    }
}

extension AuthenticationViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.viewModel.signIn(withApple: authorization)
    }
}

extension AuthenticationViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
