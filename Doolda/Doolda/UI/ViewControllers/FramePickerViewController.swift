//
//  FramePickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import Combine
import UIKit

import SnapKit

protocol FramePickerViewControllerDelegate: AnyObject {
    func photoFrameDidChange(_ photoFrameType: PhotoFrameType)
}

final class FramePickerViewController: UIViewController {

    // MARK: - Subviews
    
    private lazy var photoFrameCollecionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        let carouselInsetX: CGFloat = 50.0
        collectionView.contentInset = UIEdgeInsets(top: 0, left: carouselInsetX / 2, bottom: 0, right: carouselInsetX / 2)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            PhotoFrameCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoFrameCollectionViewCell.photoPickerFrameCellIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = PhotoFrameType.allCases.count
        return pageControl
    }()
    
    // MARK: - Private Properties
    
    private weak var delegate: FramePickerViewControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var currentItemIndex: Int = 0
    
    // MARK: - Initializers
    
    convenience init(framePickerViewControllerDelegate: FramePickerViewControllerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = framePickerViewControllerDelegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.addSubview(self.photoFrameCollecionView)
        self.photoFrameCollecionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    func bindUI() {
        self.$currentItemIndex
            .sink { [weak self] index in
                guard let self = self else { return }
                self.pageControl.currentPage = index
                self.delegate?.photoFrameDidChange(PhotoFrameType.allCases[self.currentItemIndex])
            }
            .store(in: &self.cancellables)
    }
}

extension FramePickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right),
            height: collectionView.bounds.height
        )
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = self.photoFrameCollecionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let insetX = (self.photoFrameCollecionView.contentInset.left + self.photoFrameCollecionView.contentInset.right)
        let itemWidth = self.photoFrameCollecionView.bounds.width + layout.minimumLineSpacing - insetX
        var offset = targetContentOffset.pointee
        
        let index = Int(round((offset.x + self.photoFrameCollecionView.contentInset.left) / itemWidth))
        
        if self.currentItemIndex > index {
            self.currentItemIndex = max(self.currentItemIndex - 1, 0)
        } else if self.currentItemIndex < index {
            self.currentItemIndex += 1
        }
        
        offset = CGPoint(x: CGFloat(self.currentItemIndex) * itemWidth - self.photoFrameCollecionView.contentInset.left, y: 0)
                    
        targetContentOffset.pointee = offset
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoFrameType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoFrameCollectionViewCell.photoPickerFrameCellIdentifier,
            for: indexPath
        )
        
        if let photoFrameCollectionViewCell = cell as? PhotoFrameCollectionViewCell,
           let baseImage = PhotoFrameType.allCases[indexPath.item].rawValue?.baseImage {
             
            photoFrameCollectionViewCell.fill(baseImage)
        }
        
        return cell
    }
}
