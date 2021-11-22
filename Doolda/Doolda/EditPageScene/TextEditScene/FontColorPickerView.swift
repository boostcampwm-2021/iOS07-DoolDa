//
//  FontColorPickerView.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/22.
//

import Combine
import UIKit

import SnapKit

class FontColorPickerView: UIView {

    // MARK: - Subviews

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(PackedStickerCollectionViewCell.self, forCellWithReuseIdentifier: PackedStickerCollectionViewCell.identifier)
        return collectionView
    }()

    // MARK: - Public Properties

    @Published var currentPack: Int = .zero

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialiazers

    convenience init(
        collectionViewDelegate: UICollectionViewDelegate? = nil,
        collectionViewDataSource: UICollectionViewDataSource? = nil,
        collectionViewLayout: UICollectionViewCompositionalLayout
    ) {
        self.init(frame: .zero)
        self.collectionView.delegate = collectionViewDelegate
        self.collectionView.dataSource = collectionViewDataSource
        self.collectionView.collectionViewLayout = collectionViewLayout

        self.configureUI()
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

    }

    private func bindUI() {
        self.$currentPack
            .sink { [weak self] index in
                guard let self = self else { return }
                self.pageControl.currentPage = index
            }
            .store(in: &self.cancellables)
    }

}
