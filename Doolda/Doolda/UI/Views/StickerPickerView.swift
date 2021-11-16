//
//  StickerPickerView.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import UIKit

import SnapKit

class StickerPickerView: UIView {

    // MARK: - Subviews

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
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

    convenience init(
        collectionViewDelegate: UICollectionViewDelegate? = nil,
        collectionViewDataSource: UICollectionViewDataSource? = nil
    ) {
        self.init(frame: .zero)
        self.collectionView.delegate = collectionViewDelegate
        self.collectionView.dataSource = collectionViewDataSource

        configureUI()
    }

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
    }

}
