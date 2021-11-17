//
//  DiaryCollectionViewHeader.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Combine
import UIKit

import SnapKit

class DiaryCollectionViewHeader: UICollectionReusableView {
    
    // MARK: - Static Properties
    
    static let reusableViewIdentifier = "DiaryCollectionViewHeader"
    
    // MARK: - Subviews
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(.refresh, for: .normal)
        button.tintColor = .dooldaLabel
        return button
    }()
    
    private lazy var addPageButton: UIButton = {
        let button = UIButton()
        button.setImage(.plus, for: .normal)
        button.tintColor = .dooldaLabel
        return button
    }()
    
    private lazy var headerCardView: UIView = {
        let view = UIView()
        return view
    }()
    
    var displayMode: DiaryDisplayMode? {
        didSet { self.updateLayout() }
    }
    
    var isMyTurn: Bool = false {
        didSet { self.updateMode() }
    }
    
    var isRefreshing: Bool = false {
        didSet { self.updateMode() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.bindUI()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    weak var delegate: DiaryCollectionViewHeaderDelegate?
    
    private var listConstraint: Constraint?
    private var carouselConstraint: Constraint?
    
    private func configureUI() {
        self.addSubview(self.headerCardView)
        
        self.headerCardView.backgroundColor = .yellow
        self.headerCardView.snp.makeConstraints { make in
            make.center.leading.trailing.equalToSuperview()
            self.listConstraint = make.height.equalToSuperview().priority(.medium).constraint
            self.carouselConstraint = make.height.equalTo(self.headerCardView.snp.width).multipliedBy(30.0 / 17.0).priority(.required).constraint
        }
        
        self.headerCardView.addSubview(self.refreshButton)
        self.refreshButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.headerCardView.addSubview(self.addPageButton)
        self.addPageButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindUI() {
        self.refreshButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.refreshButtonDidTap(self)
            }
            .store(in: &self.cancellables)
        
        self.addPageButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.addPageButtonDidTap(self)
            }
            .store(in: &self.cancellables)
    }
    
    private func updateMode() {
        let state = (self.isMyTurn, self.isRefreshing)
        switch state {
        case let(isMyTurn, isRefreshing) where !isMyTurn && isRefreshing:
            self.refreshButton.isHidden = true
            self.addPageButton.isHidden = true
        case let(isMyTurn, isRefreshing) where !isMyTurn && !isRefreshing:
            self.refreshButton.isHidden = false
            self.addPageButton.isHidden = true
        case let(isMyTurn, isRefreshing) where isMyTurn && !isRefreshing:
            self.refreshButton.isHidden = true
            self.addPageButton.isHidden = false
        default:
            return
        }
    }
    
    private func updateLayout() {
        guard let displayMode = displayMode else { return }
        
        switch displayMode {
        case .list:
            self.carouselConstraint?.deactivate()
            self.listConstraint?.activate()
        case .carousel:
            self.carouselConstraint?.activate()
            self.listConstraint?.deactivate()
        }
    }
}

protocol DiaryCollectionViewHeaderDelegate: AnyObject {
    func refreshButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader)
    func addPageButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader)
}
