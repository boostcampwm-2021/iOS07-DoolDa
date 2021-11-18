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
        let layout = self.createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(PackedStickerCell.self, forCellWithReuseIdentifier: PackedStickerCell.identifier)
        collectionView.register(UnpackedStickerCell.self, forCellWithReuseIdentifier: UnpackedStickerCell.identifier)
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

    // MARK: - Public Methods

    func invalidateLayout() {
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
            )
            item.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }

}
