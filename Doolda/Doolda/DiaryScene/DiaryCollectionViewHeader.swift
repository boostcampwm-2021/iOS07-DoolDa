//
//  DiaryCollectionViewHeader.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Combine
import UIKit

import SnapKit

enum DiaryCollectionViewHeaderState {
    case newPageAddable, waitingForOpponent, refreshing
}

class DiaryCollectionViewHeader: UICollectionReusableView {
    
    // MARK: - Static Properties
    
    static let identifier = "DiaryCollectionViewHeader"
    
    // MARK: - Subviews
    
    private lazy var headerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaHighlighted
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var hedgehogWritingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .hedgehogWriting
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var hedgehogImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .hedgehog
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .dooldaLabel
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .dooldaLabel
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.alpha = 0
        return activityIndicator
    }()
    
    private lazy var hapticGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        return generator
    }()
    
    // MARK: - Public Properties
    
    weak var delegate: DiaryCollectionViewHeaderDelegate?
    @Published var displayMode: DiaryDisplayMode = .carousel
    @Published var isMyTurn: Bool = false
    @Published var isRefreshing: Bool = false

    // MARK: - Private Properties
    
    private var listCardConstraint: Constraint?
    private var carouselCardConstraint: Constraint?
    private var leftHedgehogShowingConstraint: Constraint?
    private var leftHedgehogHidingConstraint: Constraint?
    private var rightHedgehogShowingConstraint: Constraint?
    private var rightHedgehogHidingConstraint: Constraint?
    private var cancellables: Set<AnyCancellable> = []
    @Published private var headerState: DiaryCollectionViewHeaderState = .newPageAddable
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.configureFont()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.configureFont()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.addSubview(self.headerCardView)
        
        self.headerCardView.snp.makeConstraints { make in
            make.center.leading.trailing.equalToSuperview()
            self.listCardConstraint = make.height.equalToSuperview().priority(.medium).constraint
            self.carouselCardConstraint = make.height.equalTo(self.headerCardView.snp.width).multipliedBy(30.0 / 17.0).constraint
        }
        
        self.headerCardView.addSubview(self.hedgehogWritingImageView)
        self.hedgehogWritingImageView.snp.makeConstraints { make in
            make.width.equalTo(242)
            make.height.equalTo(245)
            make.centerY.equalToSuperview().offset(-20)
            self.leftHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.leading).offset(20).constraint
            self.leftHedgehogHidingConstraint = make.trailing.equalTo(self.headerCardView.snp.leading).priority(.medium).constraint
        }
        
        self.headerCardView.addSubview(self.hedgehogImageView)
        self.hedgehogImageView.snp.makeConstraints { make in
            make.width.equalTo(242)
            make.height.equalTo(245)
            make.centerY.equalToSuperview().offset(-20)
            self.rightHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.trailing).offset(-20).constraint
            self.rightHedgehogHidingConstraint = make.leading.equalTo(self.headerCardView.snp.trailing).priority(.medium).constraint
        }
        
        self.headerCardView.addSubview(self.titleStackView)
        self.titleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.hedgehogWritingImageView.snp.trailing)
            make.trailing.equalTo(self.hedgehogImageView.snp.leading)
        }
        
        self.headerCardView.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindUI() {
        Publishers.CombineLatest(self.$isMyTurn, self.$isRefreshing)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isMyTurn, isRefreshing in
                switch (isMyTurn, isRefreshing) {
                case let(isMyTurn, _) where isMyTurn: self?.headerState = .newPageAddable
                case let(isMyTurn, isRefreshing) where !isMyTurn && !isRefreshing: self?.headerState = .waitingForOpponent
                case let(isMyTurn, isRefreshing) where !isMyTurn && isRefreshing: self?.headerState = .refreshing
                default: break
                }
            }
            .store(in: &self.cancellables)

        self.headerCardView.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                switch self.headerState {
                case .newPageAddable: self.delegate?.addPageButtonDidTap(self)
                case .waitingForOpponent: self.delegate?.refreshButtonDidTap(self)
                default: break
                }
            }
            .store(in: &self.cancellables)
        
        self.$displayMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                guard let self = self else { return }
                self.updateView(with: displayMode)
                self.remakeConstraints(with: displayMode)
                self.updateView(with: self.headerState)
            }
            .store(in: &self.cancellables)

        self.$headerState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] headerState in
                UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseOut) { [weak self] in
                    self?.updateView(with: headerState)
                }
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    private func updateView(with displayMode: DiaryDisplayMode) {
        switch displayMode {
        case .list:
            self.titleLabel.font = .systemFont(ofSize: 20)
            self.subtitleLabel.font = .systemFont(ofSize: 15)
            self.listCardConstraint?.activate()
            self.carouselCardConstraint?.deactivate()
        case .carousel:
            self.titleLabel.font = .systemFont(ofSize: 30)
            self.subtitleLabel.font = .systemFont(ofSize: 20)
            self.listCardConstraint?.deactivate()
            self.carouselCardConstraint?.activate()
        }
    }
    
    private func updateView(with headerState: DiaryCollectionViewHeaderState) {
        switch headerState {
        case .newPageAddable:
            self.titleLabel.text = "내가 작성할 차례에요!"
            self.subtitleLabel.text = "탭해서 작성하기"
            self.titleStackView.alpha = 1
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
            self.leftHedgehogHidingConstraint?.deactivate()
            self.leftHedgehogShowingConstraint?.activate()
            self.rightHedgehogHidingConstraint?.activate()
            self.rightHedgehogShowingConstraint?.deactivate()
            self.layoutIfNeeded()
        case .waitingForOpponent:
            self.titleLabel.text = "친구가 작성할 차례에요!"
            self.subtitleLabel.text = "탭해서 새로고침"
            self.titleStackView.alpha = 1
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
            self.leftHedgehogHidingConstraint?.activate()
            self.leftHedgehogShowingConstraint?.deactivate()
            self.rightHedgehogHidingConstraint?.deactivate()
            self.rightHedgehogShowingConstraint?.activate()
            self.layoutIfNeeded()
        case .refreshing:
            self.titleStackView.alpha = 0
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
            self.leftHedgehogHidingConstraint?.deactivate()
            self.leftHedgehogShowingConstraint?.activate()
            self.rightHedgehogHidingConstraint?.deactivate()
            self.rightHedgehogShowingConstraint?.activate()
            self.layoutIfNeeded()
        }
    }
    
    private func remakeConstraints(with displayMode: DiaryDisplayMode) {
        switch displayMode {
        case .list:
            self.titleStackView.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(self.hedgehogWritingImageView.snp.trailing)
                make.trailing.equalTo(self.hedgehogImageView.snp.leading)
            }
            self.hedgehogWritingImageView.snp.remakeConstraints { make in
                make.width.equalTo(242)
                make.height.equalTo(245)
                make.centerY.equalToSuperview().offset(-20)
                self.leftHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.leading).offset(20).constraint
                self.leftHedgehogHidingConstraint = make.trailing.equalTo(self.headerCardView.snp.leading).priority(.medium).constraint
            }
            self.hedgehogImageView.snp.remakeConstraints { make in
                make.width.equalTo(242)
                make.height.equalTo(245)
                make.centerY.equalToSuperview().offset(-20)
                self.rightHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.trailing).offset(-20).constraint
                self.rightHedgehogHidingConstraint = make.leading.equalTo(self.headerCardView.snp.trailing).priority(.medium).constraint
            }
        case .carousel:
            self.titleStackView.snp.remakeConstraints { make in
                make.centerY.equalToSuperview().offset(-150)
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            self.hedgehogWritingImageView.snp.remakeConstraints { make in
                make.width.equalTo(363)
                make.height.equalTo(367.5)
                make.centerY.equalToSuperview().offset(150)
                self.leftHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.leading).offset(10).constraint
                self.leftHedgehogHidingConstraint = make.trailing.equalTo(self.headerCardView.snp.leading).priority(.medium).constraint
            }
            self.hedgehogImageView.snp.remakeConstraints { make in
                make.width.equalTo(363)
                make.height.equalTo(367.5)
                make.centerY.equalToSuperview().offset(150)
                self.rightHedgehogShowingConstraint = make.centerX.equalTo(self.headerCardView.snp.trailing).offset(-10).constraint
                self.rightHedgehogHidingConstraint = make.leading.equalTo(self.headerCardView.snp.trailing).priority(.medium).constraint
            }
        }
    }
    
    private func configureFont() {
        switch self.displayMode {
        case .list:
            self.titleLabel.font = .systemFont(ofSize: 20)
            self.subtitleLabel.font = .systemFont(ofSize: 15)
        case .carousel:
            self.titleLabel.font = .systemFont(ofSize: 30)
            self.subtitleLabel.font = .systemFont(ofSize: 20)
        }
    }
}

// MARK: - Delegate Protocol

protocol DiaryCollectionViewHeaderDelegate: AnyObject {
    func refreshButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader)
    func addPageButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader)
}
