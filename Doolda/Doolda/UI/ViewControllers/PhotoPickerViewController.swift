//
//  PhotoPickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import UIKit

final class PhotoPickerViewController: UIViewController {
    
    static let photoPickerCellId = "photoPickerCellId"
    
    // MARK: - Subviews
    
    private lazy var photoPickerCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.photoPickerCellId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Public Properties
    
    var selectablePhotoCount: Int = 1
    
    // MARK: - Initializers
//
//    convenience init(selectablePhotoCount: Int) {
//        self.init(nibName: nil, bundle: nil)
//        self.selectablePhotoCount = selectablePhotoCount
//    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.addSubview(self.photoPickerCollectionView)
        self.photoPickerCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PhotoPickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellWidth = collectionView.bounds.width / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.photoPickerCellId, for: indexPath)
        cell.backgroundColor = .red
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        return cell
    }
}
