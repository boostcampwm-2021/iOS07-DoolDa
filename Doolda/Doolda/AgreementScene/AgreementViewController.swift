//
//  AgreementViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/12/27.
//

import Combine
import UIKit

import SnapKit

final class AgreementViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "둘다"
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "서비스 이용을 위한 약관 동의를 해주세요."
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var serviceAgreementCheckBox: DooldaCheckBox = {
        var checkBox = DooldaCheckBox()
        checkBox.text = "서비스 이용 약관(필수)"
        checkBox.textColor = .dooldaSublabel
        checkBox.spacing = 8
        return checkBox
    }()
    
    private lazy var serviceAgreementTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .dooldaTextViewBackground
        textView.layer.cornerRadius = 4
        textView.clipsToBounds = true
        textView.textColor = .black
        textView.isEditable = false
        return textView
    }()
    
    private lazy var privacyPolicyCheckBox: DooldaCheckBox = {
        var checkBox = DooldaCheckBox()
        checkBox.text = "개인정보 처리 방침(필수)"
        checkBox.textColor = .dooldaSublabel
        checkBox.spacing = 8
        return checkBox
    }()
    
    private lazy var privacyPolicyTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .dooldaTextViewBackground
        textView.layer.cornerRadius = 4
        textView.clipsToBounds = true
        textView.textColor = .black
        textView.isEditable = false
        return textView
    }()
    
    private lazy var pairButton: DooldaButton = {
        let button = DooldaButton()
        button.setTitle("친구 연결하기", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Private Properties
    
    private var viewModel: AgreementViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(viewModel: AgreementViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    deinit {
        self.viewModel.deinitRequested()
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureFont()
        bindUI()
        self.viewModel.viewDidLoad()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.centerY.equalToSuperview().priority(.low)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.serviceAgreementCheckBox)
        self.serviceAgreementCheckBox.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        
        self.contentView.addSubview(self.serviceAgreementTextView)
        self.serviceAgreementTextView.snp.makeConstraints { make in
            make.top.equalTo(self.serviceAgreementCheckBox.snp.bottom).offset(7)
            make.height.equalTo(180)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.privacyPolicyCheckBox)
        self.privacyPolicyCheckBox.snp.makeConstraints { make in
            make.top.equalTo(self.serviceAgreementTextView.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        
        self.contentView.addSubview(self.privacyPolicyTextView)
        self.privacyPolicyTextView.snp.makeConstraints { make in
            make.top.equalTo(self.privacyPolicyCheckBox.snp.bottom).offset(7)
            make.height.equalTo(180)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.pairButton)
        self.pairButton.snp.makeConstraints { make in
            make.top.equalTo(self.privacyPolicyTextView.snp.bottom).offset(20)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func configureFont() {
        self.titleLabel.font = UIFont(name: FontType.dovemayo.name, size: 72)
        self.subtitleLabel.font = UIFont(name: FontType.dovemayo.name, size: 18)
        self.serviceAgreementCheckBox.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.privacyPolicyCheckBox.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.pairButton.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 14)
    }
    
    private func bindUI() {
        self.privacyPolicyCheckBox.$value
            .sink { [weak self] isChecked in
                self?.viewModel.privacyPolicyCheckBoxInput = isChecked
            }
            .store(in: &self.cancellables)
        
        self.serviceAgreementCheckBox.$value
            .sink { [weak self] isChecked in
                self?.viewModel.serviceAgreementCheckBoxInput = isChecked
            }
            .store(in: &self.cancellables)
        
        self.viewModel.isPossibleToSignUpPublisher
            .sink { isPossibleToSignUp in
                self.pairButton.isEnabled = isPossibleToSignUp
            }
            .store(in: &self.cancellables)
        
        self.viewModel.privacyPolicyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] privacyPolicy in
                self?.privacyPolicyTextView.text = privacyPolicy
            }
            .store(in: &self.cancellables)
        
        self.viewModel.serviceAgreementPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] serviceAgreement in
                self?.serviceAgreementTextView.text = serviceAgreement
            }
            .store(in: &self.cancellables)
        
        self.pairButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.pairButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.viewModel.errorPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController.defaultAlert(title: "오류", message: message, handler: { _ in })
        self.present(alert, animated: true)
    }
}
