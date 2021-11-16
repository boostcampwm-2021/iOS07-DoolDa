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
        let collectionView = UICollectionView(frame: .zero)
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
        
    }

}
