//
//  PhotoPickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import Combine
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
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.minimumInteritemSpacing = 0.5
        flowLayout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            PhotoPickerCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Public Properties
    
    var selectablePhotoCount: Int = 1
    
    // MARK: - Private Properties
    
    private weak var delegate: PhotoPickerViewControllerDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    @Published private var selectedItems: [Int] = []
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
            
            if self.selectedItems.contains(indexPath.item),
               let target = self.selectedItems.enumerated().first(where: { $0.element == indexPath.item }) {
                photoPickerCollectionViewCell.select(order: target.offset + 1)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoPickerCollectionViewCell else { return }
        
        if self.selectedItems.contains(indexPath.item),
           let target = self.selectedItems.enumerated().first(where: { $0.element == indexPath.item }) {
            self.selectedItems.remove(at: target.offset)
            cell.deselect()
            collectionView.reloadData()
        } else {
            cell.select(order: self.selectedItems.count + 1)
            self.selectedItems.append(indexPath.item)
        }
    }
}
