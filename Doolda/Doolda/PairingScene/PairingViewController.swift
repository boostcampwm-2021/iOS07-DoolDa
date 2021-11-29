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
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(.refresh, for: .normal)
        return button
    }()
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.text = "둘다"
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.text = "서로의 초대코드를 입력하여 연결해 주세요"
        return label
    }()
    
    private lazy var myIdTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaSublabel
        label.text = "내 초대코드"
        return label
    }()
    
    private lazy var myIdLabel: CopyableLabel = {
        let label = CopyableLabel()
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        label.text = "12345678–1234–1234–1234–1234567890ab"
        return label
    }()
    
    private lazy var friendIdTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaSublabel
        label.text = "상대방 초대코드를 전달 받으셨나요?"
        return label
    }()
    
    private lazy var friendIdTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .dooldaLabel
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var pairButton: UIButton = {
        let button = DooldaButton()
        button.setTitle("연결하기", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.isEnabled = false
        return button
    }()

    private lazy var pairSkipButton: UIButton = {
        let button = DooldaButton()
        button.setTitle("혼자 쓰러가기", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        return button
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaSublabel
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
    
    private lazy var hapticGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        return generator
    }()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: PairingViewModel!
    
    // MARK: - Initializers
    
    convenience init(viewModel: PairingViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.refreshButton)
        self.refreshButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.scrollView.addSubview(contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.centerY.equalToSuperview().priority(.low)
        }
        
        self.contentView.addSubview(self.logoLabel)
        self.logoLabel.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.instructionLabel)
        self.instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.logoLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.pairingInfoStackView)
        self.pairingInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(self.instructionLabel.snp.bottom).offset(42)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        self.contentView.addSubview(self.pairButton)
        self.pairButton.snp.makeConstraints { make in
            make.top.equalTo(self.pairingInfoStackView.snp.bottom).offset(44)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)

        }

        self.contentView.addSubview(self.pairSkipButton)
        self.pairSkipButton.snp.makeConstraints { make in
            make.top.equalTo(self.pairButton.snp.bottom).offset(20)
            make.height.equalTo(self.pairButton)
            make.leading.equalTo(self.pairButton)
            make.trailing.equalTo(self.pairButton)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureFont() {
        self.logoLabel.font = UIFont(name: FontType.dovemayo.name, size: 72)
        self.instructionLabel.font = .systemFont(ofSize: 18)
        self.myIdTitleLabel.font = .systemFont(ofSize: 14)
        self.myIdLabel.font = .systemFont(ofSize: 16)
        self.friendIdTitleLabel.font = .systemFont(ofSize: 14)
        self.friendIdTextField.font = .systemFont(ofSize: 16)
        self.pairButton.titleLabel?.font = .systemFont(ofSize: 14)
        self.pairSkipButton.titleLabel?.font = .systemFont(ofSize: 14)
    }
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
        self.refreshButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hapticGenerator.prepare()
                self?.hapticGenerator.impactOccurred()
                viewModel.refreshButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.friendIdTextField.publisher(for: .editingChanged)
            .receive(on: DispatchQueue.main)
            .compactMap { ($0 as? UITextField)?.text }
            .assign(to: \.friendIdInput, on: viewModel)
            .store(in: &self.cancellables)
        
        self.pairButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hapticGenerator.prepare()
                self?.hapticGenerator.impactOccurred()
                viewModel.pairButtonDidTap()
            }
            .store(in: &self.cancellables)

        self.pairSkipButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hapticGenerator.prepare()
                self?.hapticGenerator.impactOccurred()
                self?.viewModel.pairSkipButtonDidTap()
            }
            .store(in: &self.cancellables)

        self.viewModel.myId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myId in
                self?.myIdLabel.text = myId
            }
            .store(in: &self.cancellables)
        
        self.viewModel.isFriendIdValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.pairButton.isEnabled = isValid
            }
            .store(in: &self.cancellables)

        self.viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let error = error as? LocalizedError else { return }
                self?.presentAlert(message: error.localizedDescription)
            }
            .store(in: &self.cancellables)

        self.view.publisher(for: UITapGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.friendIdTextField.resignFirstResponder()
            }
            .store(in: &self.cancellables)
        
        UIResponder.keyboardHeightPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyboardHeight in
                self?.updateScrollView(with: keyboardHeight)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.userPairedWithFriend, object: nil)
            .sink { [weak self] _ in
                self?.hapticGenerator.prepare()
                self?.hapticGenerator.impactOccurred()
                self?.viewModel.userPairedWithFriendNotificationDidReceived()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods
    
    private func updateScrollView(with keyboardHeight: CGFloat) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        if keyboardHeight != 0 {
            self.scrollView.contentOffset = CGPoint(x: 0, y: (keyboardHeight + self.contentView.frame.height) - self.view.frame.height + 30)
        }
    }

    private func presentAlert(message: String) {
        let alert = UIAlertController.defaultAlert(
            title: "연결 오류",
            message: message,
            handler: { _ in }
        )
        self.present(alert, animated: true)
    }
}
