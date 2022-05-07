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
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var emailStateLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 형식이 올바르지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        textField.leftViewMode = .always
        textField.textColor = .dooldaLabel
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var passwordStateLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 형식이 올바르지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        textField.leftViewMode = .always
        textField.textColor = .dooldaLabel
        return textField
    }()
    
    private lazy var passwordCheckLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var passwordCheckStateLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호가 일치하지 않습니다."
        label.textColor = .red
        return label
    }()
    
    private lazy var passwordCheckTextField: UITextField = {
        let textField = UITextField()
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        textField.leftViewMode = .always
        textField.textColor = .dooldaLabel
        return textField
    }()
    
    private lazy var emailDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaSublabel
        return view
    }()
    
    private lazy var emailInfoStack: UIStackView = {
        let titleStackView = UIStackView(arrangedSubviews: [self.emailLabel, self.emailStateLabel])
        titleStackView.distribution = .equalSpacing
        titleStackView.axis = .horizontal
        let stackView = UIStackView(arrangedSubviews: [
            titleStackView,
            emailTextField,
            self.emailDivider
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.setCustomSpacing(6, after: self.emailTextField)
        return stackView
    }()
    
    private lazy var passwordDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaSublabel
        return view
    }()
    
    private lazy var passwordInfoStack: UIStackView = {
        let titleStackView = UIStackView(arrangedSubviews: [self.passwordLabel, self.passwordStateLabel])
        titleStackView.distribution = .equalSpacing
        titleStackView.axis = .horizontal
        let stackView = UIStackView(arrangedSubviews: [
            titleStackView,
            self.passwordTextField,
            self.passwordDivider
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.setCustomSpacing(6, after: self.passwordTextField)
        return stackView
    }()
    
    private lazy var passwordCheckDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaSublabel
        return view
    }()
    
    private lazy var passwordCheckInfoStack: UIStackView = {
        let titleStackView = UIStackView(arrangedSubviews: [self.passwordCheckLabel, self.passwordCheckStateLabel])
        titleStackView.distribution = .equalSpacing
        titleStackView.axis = .horizontal
        let stackView = UIStackView(arrangedSubviews: [
            titleStackView,
            self.passwordCheckTextField,
            self.passwordCheckDivider
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.setCustomSpacing(6, after: self.passwordCheckTextField)
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
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.view.frame.height * 0.20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.signUpInfoStackView)
        self.signUpInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(42)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.emailTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
        }
        
        self.passwordTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
        }
        
        self.passwordCheckTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
        }
        
        self.emailDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        self.passwordDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        self.passwordCheckDivider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        self.view.addSubview(self.signUpButton)
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
        self.emailLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.emailStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.emailTextField.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordTextField.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordCheckLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordCheckStateLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.passwordCheckTextField.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.signUpButton.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 14)
    }
}
