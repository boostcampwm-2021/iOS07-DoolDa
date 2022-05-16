//
//  DooldaTextField.swift
//  Doolda
//
//  Created by heizel.nut on 2022/05/09.
//

import Combine
import UIKit

import SnapKit

class DooldaTextField: UIControl {
    
    // MARK: - Subviews
    
    private lazy var titleLable: UILabel = {
        var label = UILabel()
        label.textColor = .dooldaSublabel
        label.textAlignment = .left
        label.font = UIFont(name: FontType.dovemayo.name, size: 14)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: FontType.dovemayo.name, size: 16)
        textField.textColor = .dooldaLabel
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 25, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var divider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .dooldaSublabel
        return divider
    }()
    
    // MARK: - Public Properties

    var returnPublisher: AnyPublisher<UIControl, Never> {
        self.textField.publisher(for: .editingDidEndOnExit).eraseToAnyPublisher()
    }
    
    var textPublisher: AnyPublisher<String?, Never> {
        self.textField.publisher(for: \.text).eraseToAnyPublisher()
    }

    var textPublisher: AnyPublisher<String, Never> {
        self.textField.publisher(for: .editingChanged)
            .compactMap {($0 as? UITextField)?.text}
            .eraseToAnyPublisher()
    }

    var text: String? {
        get { return self.textField.text }
    }
    
    var titleText: String? {
        get { return self.titleLable.text }
        set { self.titleLable.text = newValue }
    }

    var placeholder: String? {
        get { return self.textField.placeholder }
        set { self.textField.placeholder = newValue }
    }
    
    var returnKeyType: UIReturnKeyType {
        get { return self.textField.returnKeyType }
        set { self.textField.returnKeyType = newValue}
    }

    var textContentType: UITextContentType {
        get { return self.textField.textContentType }
        set { self.textField.textContentType = newValue }
    }

    var isSecureTextEntry: Bool {
        get { return self.textField.isSecureTextEntry }
        set { self.textField.isSecureTextEntry = newValue }
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
        self.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        self.addSubview(self.titleLable)
        self.titleLable.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(self.textField)
        self.textField.snp.makeConstraints { make in
            make.top.equalTo(self.titleLable.snp.bottom).offset(24)
            make.leading.trailing.equalTo(self.titleLable)
        }
        
        self.addSubview(self.divider)
        self.divider.snp.makeConstraints { make in
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self.titleLable)
            make.height.equalTo(1)
        }

    }
    
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return self.textField.resignFirstResponder()
    }
    
}
