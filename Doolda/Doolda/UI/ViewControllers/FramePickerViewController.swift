//
//  FramePickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/10.
//

import UIKit

import SnapKit

final class FramePickerViewController: UIViewController {

    // MARK: - Static Properties
    
    static let photoPickerFrameCellId = "photoPickerFrameCellId"
    
    // MARK: - Subviews
    
    private lazy var photoFrameCollecionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: self.carouselInsetX / 2, bottom: 0, right: self.carouselInsetX / 2)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.photoPickerFrameCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 5
        return pageControl
    }()
    
    // MARK: - Private Properties
    
    private let carouselInsetX: CGFloat = 50.0
    
    private var currentItemIndex: Int = 0
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
}

extension FramePickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width - self.carouselInsetX, height: collectionView.bounds.height)
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = self.photoFrameCollecionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemWidth = self.photoFrameCollecionView.bounds.width + layout.minimumLineSpacing - self.carouselInsetX
        var offset = targetContentOffset.pointee
        
        let index = Int(round((offset.x + self.photoFrameCollecionView.contentInset.left) / itemWidth))
        
        if self.currentItemIndex > index {
            self.currentItemIndex = max(self.currentItemIndex - 1, 0)
        } else if self.currentItemIndex < index {
            self.currentItemIndex += 1
        }
        
        offset = CGPoint(x: CGFloat(currentItemIndex) * itemWidth - self.photoFrameCollecionView.contentInset.left, y: 0)
                    
        targetContentOffset.pointee = offset
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.photoPickerFrameCellId, for: indexPath)
        
        cell.backgroundColor = .orange
        
        return cell
    }
}
