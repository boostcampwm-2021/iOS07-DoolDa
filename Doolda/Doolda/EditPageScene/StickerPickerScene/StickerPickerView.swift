//
//  StickerPickerView.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import Combine
import UIKit

import SnapKit

class StickerPickerView: UIView {

    // MARK: - Subviews

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(PackedStickerCollectionViewCell.self, forCellWithReuseIdentifier: PackedStickerCollectionViewCell.identifier)
        collectionView.register(UnpackedStickerCollectionViewCell.self, forCellWithReuseIdentifier: UnpackedStickerCollectionViewCell.identifier)
        collectionView.register(
            StickerPickerCollectionViewFooter.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: StickerPickerCollectionViewFooter.identifier
        )
        return collectionView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .dooldaLabel
        pageControl.pageIndicatorTintColor = .dooldaHighlighted
        return pageControl
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

        self.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView.snp.bottom)
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(20)
        }

        self.pageControl.numberOfPages = self.collectionView.dataSource?.numberOfSections?(in: self.collectionView) ?? 0
        self.pageControl.currentPage = 0

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
