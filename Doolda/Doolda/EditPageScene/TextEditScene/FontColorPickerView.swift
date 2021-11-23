//
//  FontColorPickerView.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/22.
//

import UIKit

import SnapKit

class FontColorPickerView: UIView {

    // MARK: - Subviews

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 15
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.register(FontColorCollectionViewCell.self, forCellWithReuseIdentifier: FontColorCollectionViewCell.identifier)
        
        return collectionView
    }()

    // MARK: - Initialiazers

    convenience init(
        frame: CGRect,
        collectionViewDelegate: UICollectionViewDelegate? = nil,
        collectionViewDataSource: UICollectionViewDataSource? = nil
    ) {
        self.init(frame: frame)
        self.collectionView.delegate = collectionViewDelegate
        self.collectionView.dataSource = collectionViewDataSource
        
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

