//
//  SignUpViewController.swift
//  Doolda
//
//  Created by 정지승 on 2022/05/07.
//

import UIKit

import SnapKit

final class SignUpViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
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
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.signInButton)
        self.scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.signInButton.snp.top).offset(-12)
        }
        
        self.signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-38)
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().priority(.low)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.signUpInfoStackView)
        self.signUpInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(42)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.signUpButton)
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.signUpInfoStackView.snp.bottom).offset(44)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
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
}
