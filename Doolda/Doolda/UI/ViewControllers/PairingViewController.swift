//
//  PairingViewController.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import Combine
import UIKit

import SnapKit

class PairingViewController: UIViewController {
    // MARK: - Subviews
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(.refresh, for: .normal)
        return button
    }()
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to dovemayo
        label.font = .systemFont(ofSize: 72, weight: .regular)
        label.textColor = .dooldaLabel
        label.text = "둘다"
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to global font
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .dooldaLabel
        label.text = "서로의 초대코드를 입력하여 연결해 주세요"
        return label
    }()
    
    private lazy var myIdTitleLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to global font
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .dooldaSubLabel
        label.text = "내 초대코드"
        return label
    }()
    
    private lazy var myIdLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to global font
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        label.text = "12345678–1234–1234–1234–1234567890ab"
        return label
    }()
    
    private lazy var friendIdTitleLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to global font
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .dooldaSubLabel
        label.text = "상대방 초대코드를 전달 받으셨나요?"
        return label
    }()
    
    private lazy var friendIdTextField: UITextField = {
        let textField = UITextField()
        // MARK: - FIXME : change font to global font
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.placeholder = "전달 받은 초대코드 입력"
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var pairButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        var container = AttributeContainer()
        // MARK: - FIXME : change font to global font
        container.font = .systemFont(ofSize: 16, weight: .regular)
        configuration.attributedTitle = AttributedString("연결하기", attributes: container)
        configuration.baseBackgroundColor = .dooldaTheme
        configuration.baseForegroundColor = .dooldaLabel
        let button = UIButton(configuration: configuration)
        button.isEnabled = false
        return button
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaSubLabel
        return view
    }()
    
    private lazy var pairingInfoStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.myIdTitleLabel,
                self.myIdLabel,
                self.friendIdTitleLabel,
                self.friendIdTextField,
                self.divider
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.setCustomSpacing(6, after: friendIdTextField)
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.refreshButton)
        
        self.view.addSubview(self.logoLabel)
        self.logoLabel.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.instructionLabel)
        self.instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.logoLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.pairingInfoStackView)
        self.pairingInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.instructionLabel.snp.bottom).offset(42)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        self.view.addSubview(self.pairButton)
        self.pairButton.snp.makeConstraints { make in
            make.top.equalTo(self.pairingInfoStackView.snp.bottom).offset(44)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - FIXME : ViewModel binding needed
    
    private func bindUI() {
        self.refreshButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("refresh button did tap")
//                self?.viewModel.refreshButtonDidTap()
            }
            .store(in: &cancellables)
        
        self.friendIdTextField.publisher(for: .editingChanged)
            .receive(on: DispatchQueue.main)
            .compactMap { ($0 as? UITextField)?.text }
            .sink(receiveValue: {
                print($0)
            })
//            .assign(to: \.friendId, on: viewModel)
            .store(in: &cancellables)
            
        self.pairButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("pair button did tap")
//                self?.viewModel.pairButtonDidTap()
            }
            .store(in: &cancellables)
        
//        self.viewModel.$isFriendIdValid
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isValid in
//                self?.pairButton.isEnabled = isValid
//            }
//            .store(in: &cancellables)
    }
}
