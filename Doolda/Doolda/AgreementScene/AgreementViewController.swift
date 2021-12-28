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
    
    private lazy var serviceAgreementTitleLabel: UILabel = {
        var label = UILabel()
        label.text = "서비스 이용 약관"
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var serviceAgreementTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .dooldaTextViewBackground
        // FIXME: viewModel bind완료 후 text 제거
        textView.text = "Sample1"
        textView.textColor = .black
        textView.isEditable = false
        return textView
    }()
    
    private lazy var privacyPolicyTitleLabel: UILabel = {
        var label = UILabel()
        label.text = "개인정보 처리 방침"
        label.textColor = .dooldaSublabel
        return label
    }()
    
    private lazy var privacyPolicyTextView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .dooldaTextViewBackground
        // FIXME: viewModel bind완료 후 text 제거
        textView.text = "Sample2"
        textView.textColor = .black
        textView.isEditable = false
        return textView
    }()
    
    private lazy var nextButton: DooldaButton = {
        let button = DooldaButton()
        button.setTitle("동의하고 친구 연결하기", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        return button
    }()
    
    // MARK: - Private Properties
    
    private var viewModel: AgreementViewModel!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(viewModel: AgreementViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    deinit {
        // FIXME: ViewModel의 Deinit Input 연결
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureFont()
        bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.isHidden = true
        
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
        
        self.contentView.addSubview(self.serviceAgreementTitleLabel)
        self.serviceAgreementTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(16)
        }
        
        self.contentView.addSubview(self.serviceAgreementTextView)
        self.serviceAgreementTextView.snp.makeConstraints { make in
            make.top.equalTo(self.serviceAgreementTitleLabel.snp.bottom).offset(7)
            make.height.equalTo(180)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.privacyPolicyTitleLabel)
        self.privacyPolicyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.serviceAgreementTextView.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
        }
        
        self.contentView.addSubview(self.privacyPolicyTextView)
        self.privacyPolicyTextView.snp.makeConstraints { make in
            make.top.equalTo(self.privacyPolicyTitleLabel.snp.bottom).offset(7)
            make.height.equalTo(180)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { make in
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
        self.serviceAgreementTitleLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.privacyPolicyTitleLabel.font = UIFont(name: FontType.dovemayo.name, size: 14)
        self.nextButton.titleLabel?.font = UIFont(name: FontType.dovemayo.name, size: 14)
    }
    
    private func bindUI() {
        // FIXME: ViewModel과 병합 후 작성
    }
}