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
        // FIXME : change font to dovemayo
        label.font = UIFont(name: "Dovemayo", size: 72)
        label.textColor = .dooldaLabel
        label.text = "둘다"
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        // FIXME : change font to global font
        label.font = UIFont(name: "Dovemayo", size: 18)
        label.textColor = .dooldaLabel
        label.text = "서로의 초대코드를 입력하여 연결해 주세요"
        return label
    }()
    
    private lazy var myIdTitleLabel: UILabel = {
        let label = UILabel()
        // FIXME : change font to global font
        label.font = UIFont(name: "Dovemayo", size: 14)
        label.textColor = .dooldaSubLabel
        label.text = "내 초대코드"
        return label
    }()
    
    private lazy var myIdLabel: CopyableLabel = {
        let label = CopyableLabel()
        // FIXME : change font to global font
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.textAlignment = .center
        label.text = "12345678–1234–1234–1234–1234567890ab"
        return label
    }()
    
    private lazy var friendIdTitleLabel: UILabel = {
        let label = UILabel()
        // FIXME : change font to global font
        label.font = UIFont(name: "Dovemayo", size: 14)
        label.textColor = .dooldaSubLabel
        label.text = "상대방 초대코드를 전달 받으셨나요?"
        return label
    }()
    
    private lazy var friendIdTextField: UITextField = {
        let textField = UITextField()
        // FIXME : change font to global font
        textField.font = UIFont(name: "Dovemayo", size: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "전달 받은 초대코드 입력",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.dooldaPlaceholder as Any]
        )
        textField.textColor = .dooldaLabel
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var pairButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        var container = AttributeContainer()
        // FIXME : change font to global font
        container.font = UIFont(name: "Dovemayo", size: 16)
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
    
    private let transparentNavigationBarAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        appearance.configureWithTransparentBackground()
        return appearance
    }()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: PairingViewModel?
    
    // MARK: - Initializers
    
    convenience init(viewModel: PairingViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.standardAppearance = transparentNavigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = transparentNavigationBarAppearance
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaTheme
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.refreshButton)
        
        self.view.addSubview(scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.addSubview(contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
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
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - FIXME : should bind to viewModel
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
        self.refreshButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                viewModel.refreshButtonDidTap()
            }
            .store(in: &cancellables)
        
        self.friendIdTextField.publisher(for: .editingChanged)
            .receive(on: DispatchQueue.main)
            .compactMap { ($0 as? UITextField)?.text }
            .assign(to: \.friendId, on: viewModel)
            .store(in: &cancellables)
        
        self.pairButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("pair button did tap")
                viewModel.pairButtonDidTap()
            }
            .store(in: &cancellables)

        viewModel.$myId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] myId in
                self?.myIdLabel.text = myId
            }
            .store(in: &self.cancellables)
        
        viewModel.isFriendIdValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.pairButton.isEnabled = isValid
            }
            .store(in: &cancellables)
        
        self.view.publisher(for: UITapGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.friendIdTextField.resignFirstResponder()
            }
            .store(in: &cancellables)
        
        UIResponder.keyboardHeightPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyboardHeight in
                self?.updateScrollView(with: keyboardHeight)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func updateScrollView(with keyboardHeight: CGFloat) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
        if keyboardHeight != 0 {
            self.scrollView.contentOffset = CGPoint(x: 0, y: (keyboardHeight + self.contentView.frame.height) - self.view.frame.height + 30)
        }
    }
}
