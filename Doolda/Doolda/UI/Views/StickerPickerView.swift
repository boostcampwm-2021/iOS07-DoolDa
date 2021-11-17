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

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0

        let layout = self.createLayout()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            PackedStickerCell.self,
            forCellWithReuseIdentifier: PackedStickerCell.identifier
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
        collectionViewDataSource: UICollectionViewDataSource? = nil
    ) {
        self.init(frame: .zero)
        self.collectionView.delegate = collectionViewDelegate
        self.collectionView.dataSource = collectionViewDataSource

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

    // MARK: - Private Methods

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            )
            item.contentInsets = .init(top: 30, leading: 100, bottom: 30, trailing: 100)

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }

}