//
//  DiaryCollectionViewHeader.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Combine
import UIKit

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
    
    private func configureUI() {
        self.addSubview(self.refreshButton)
        self.refreshButton.snp.makeConstraints { make in
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
    }
    
    private func updateMode() {
        let state = (self.isMyTurn, self.isRefreshing)
        switch state {
        case let(isMyTurn, isRefreshing) where !isMyTurn && isRefreshing:
            self.backgroundColor = .yellow
            self.refreshButton.isHidden = true
        case let(isMyTurn, isRefreshing) where !isMyTurn && !isRefreshing:
            self.backgroundColor = .red
            self.refreshButton.isHidden = false
        case let(isMyTurn, isRefreshing) where isMyTurn && !isRefreshing:
            self.backgroundColor = .blue
            self.refreshButton.isHidden = true
        default:
            return
        }
    }
}

protocol DiaryCollectionViewHeaderDelegate: AnyObject {
    func refreshButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader)
}
