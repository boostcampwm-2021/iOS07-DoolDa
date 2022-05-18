//
//  SignUpViewController.swift
//  Doolda
//
//  Created by 정지승 on 2022/05/07.
//

import Combine
import UIKit

import SnapKit

final class SignUpViewController: UIViewController {
    
    // MARK: - Private Properties

    private var viewModel: SignUpViewModel!
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(viewModel: SignUpViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "둘다"
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "회원가입을 위한 정보를 입력해주세요."
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailTextField: DooldaTextField = {
        let textField = DooldaTextField()
        textField.titleText = "이메일"
        textField.returnKeyType = .next
        textField.textContentType = .emailAddress
        return textField
    }()
    
    private lazy var emailStateLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 형식이 올바르지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var passwordTextField: DooldaTextField = {
        let textField = DooldaTextField()
        textField.titleText = "비밀번호"
        textField.returnKeyType = .next
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var passwordStateLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 형식이 올바르지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var passwordCheckTextField: DooldaTextField = {
        let textField = DooldaTextField()
        textField.titleText = "비밀번호 확인"
        textField.returnKeyType = .done
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var passwordCheckStateLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호가 일치하지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var emailInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.emailTextField,
            self.emailStateLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 7
        return stackView
    }()

    private lazy var passwordInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.passwordTextField,
            self.passwordStateLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 7
        return stackView
    }()

    private lazy var passwordCheckInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.passwordCheckTextField,
            self.passwordCheckStateLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 7
        return stackView
    }()
    
    private lazy var signUpInfoStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                emailInfoStack,
                passwordInfoStack,
                passwordCheckInfoStack
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 18
        return stackView
    }()
    
    private lazy var signUpButton: DooldaButton = {
        let button = DooldaButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.isEnabled = false
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        var button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributeString = NSMutableAttributedString(string: "이미 계정이 있으신가요?", attributes: attributes)
        button.setAttributedTitle(attributeString, for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureFont()
        bindUI()
        bindViewModel()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.signInButton)
        self.scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.scrollView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-38)
        }
        
        self.scrollView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.signUpInfoStackView)
        self.signUpInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(42)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.signUpButton)
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.signUpInfoStackView.snp.bottom).offset(44)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureFont() {
        self.titleLabel.font = UIFont(name: FontType.dovemayo.name, size: 72)
        self.subtitleLabel.font = UIFont(name: FontType.dovemayo.name, size: 18)
        self.emailStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordCheckStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.signUpButton.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.signInButton.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 16)
    }
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] in
                guard let keyboardFrameInfo = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                self?.updateScrollView(with: keyboardFrameInfo.cgRectValue.height)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.updateScrollView(with: 0)
            }
            .store(in: &self.cancellables)
        
        self.view.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &self.cancellables)
        
        self.emailTextField.returnPublisher
            .sink { [weak self] _ in
                self?.passwordTextField.becomeFirstResponder()
            }
            .store(in: &self.cancellables)

        self.emailTextField.textPublisher
            .assign(to: \.emailInput, on: viewModel)
            .store(in: &self.cancellables)
        
        self.passwordTextField.returnPublisher
            .sink { [weak self] _ in
                self?.passwordCheckTextField.becomeFirstResponder()
            }
            .store(in: &self.cancellables)

        self.passwordTextField.textPublisher
            .assign(to: \.passwordInput, on: viewModel)
            .store(in: &self.cancellables)
        
        self.passwordCheckTextField.returnPublisher
            .sink { control in
                control.resignFirstResponder()
            }
            .store(in: &self.cancellables)

        self.passwordCheckTextField.textPublisher
            .assign(to: \.passwordCheckInput, on: viewModel)
            .store(in: &self.cancellables)

        self.signUpButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.signUpButtonDidTap()
            }
            .store(in: &self.cancellables)

        self.signInButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.signInButtonDidTap()
            }
            .store(in: &self.cancellables)
    }

    private func bindViewModel() {
        guard let viewModel = self.viewModel else { return }

        viewModel.isEmailValidPublisher.sink { [weak self] isValid in
            if isValid {
                self?.emailStateLabel.isHidden = true
            } else {
                self?.emailStateLabel.isHidden = false
            }
        }
        .store(in: &self.cancellables)

        viewModel.isPasswordValidPublisher.sink { [weak self] isValid in
            if isValid {
                self?.passwordStateLabel.isHidden = true
            } else {
                self?.passwordStateLabel.isHidden = false
            }
        }
        .store(in: &self.cancellables)

        viewModel.isPasswordCheckValidPublisher.sink { [weak self] isValid in
            if isValid {
                self?.passwordCheckStateLabel.isHidden = true
            } else {
                self?.passwordCheckStateLabel.isHidden = false
            }
        }
        .store(in: &self.cancellables)

    }
    
    private func updateScrollView(with keyboardHeight: CGFloat) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        
        if keyboardHeight != 0 {
            self.scrollView.contentOffset = CGPoint(x: 0, y: (keyboardHeight + self.scrollView.frame.height - 130) - self.view.frame.height + 30)
        }
    }
}
