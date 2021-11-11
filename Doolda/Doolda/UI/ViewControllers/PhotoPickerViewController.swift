//
//  PhotoPickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import Photos
import UIKit

protocol PhotoPickerViewControllerDelegate: AnyObject {
    func selectedPhotoDidChange(_ images: [CIImage])
}

final class PhotoPickerViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var photoPickerCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            PhotoPickerCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Public Properties
    
    var selectablePhotoCount: Int = 1
    
    // MARK: - Private Properties
    
    private weak var delegate: PhotoPickerViewControllerDelegate?
    @Published private var photos: PHFetchResult<PHAsset>?
    
    // MARK: - Initializers
    
    convenience init(photoPickerViewControllerDelegate: PhotoPickerViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = photoPickerViewControllerDelegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
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
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let cellWidth = collectionView.bounds.width / 3 - layout.minimumInteritemSpacing
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier,
            for: indexPath
        )
        
        if let photoPickerCollectionViewCell = cell as? PhotoPickerCollectionViewCell,
           let imageAsset = self.photos?.object(at: indexPath.item) {
            photoPickerCollectionViewCell.fill(imageAsset)
        }
        
        return cell
    }
}
