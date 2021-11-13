//
//  CarouselView.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/12.
//

import Combine
import UIKit

protocol CarouselViewDelegate: AnyObject {
    func selectedItemDidChange(_ index: Int)
}

class CarouselView: UIView {

    // MARK: - Subviews
    
    private lazy var photoFrameCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: self.itemInterval / 2, bottom: 0, right: self.itemInterval / 2)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            PhotoFrameCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoFrameCollectionViewCell.photoPickerFrameCellIdentifier
        )
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .dooldaLabel
        pageControl.pageIndicatorTintColor = .dooldaHighlighted
        return pageControl
    }()
    
    // MARK: - Public Properties
    
    @Published var itemInterval: CGFloat = .zero
    @Published var currentItemIndex: Int = .zero
    @Published var isPageControlHidden: Bool = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private weak var carouselDelegate: CarouselViewDelegate?
    private weak var carouselCollectionViewDataSource: UICollectionViewDataSource?
    private weak var carouselCollectionViewDelegate: UICollectionViewDelegateFlowLayout?
    
    // MARK: - Initializers
    
    convenience init(
        carouselDelegate: CarouselViewDelegate? = nil,
        carouselCollectionViewDataSource: UICollectionViewDataSource? = nil,
        carouselCollectionViewDelegate: UICollectionViewDelegateFlowLayout? = nil
    ) {
        self.init(frame: .zero)
        self.carouselDelegate = carouselDelegate
        self.carouselCollectionViewDataSource = carouselCollectionViewDataSource
        self.carouselCollectionViewDelegate = carouselCollectionViewDelegate
        self.photoFrameCollectionView.delegate = self
        self.photoFrameCollectionView.dataSource = self
        configureUI()
        bindUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.addSubview(self.photoFrameCollectionView)
        self.photoFrameCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { make in
            make.top.equalTo(self.photoFrameCollectionView.snp.bottom)
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    func bindUI() {
        self.$isPageControlHidden
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHidden in
                self?.pageControl.isHidden = isHidden
            }
            .store(in: &self.cancellables)
        
        self.$currentItemIndex
            .sink { [weak self] index in
                guard let self = self else { return }
                self.pageControl.currentPage = index
                self.carouselDelegate?.selectedItemDidChange(index)
            }
            .store(in: &self.cancellables)
        
        self.$itemInterval
            .receive(on: DispatchQueue.main)
            .sink { [weak self] insetX in
                self?.photoFrameCollectionView.contentInset = UIEdgeInsets(top: 0, left: insetX / 2, bottom: 0, right: insetX / 2)
            }
            .store(in: &self.cancellables)
    }
}

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard collectionView === self.photoFrameCollectionView else { return .zero }
        return self.carouselCollectionViewDelegate?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard self.photoFrameCollectionView === scrollView as? UICollectionView,
              let layout = self.photoFrameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemWidth = self.photoFrameCollectionView.bounds.width + layout.minimumLineSpacing - self.itemInterval
        
        let estimatedIndex = scrollView.contentOffset.x / itemWidth
        
        if velocity.x > 0 {
            self.currentItemIndex = min(Int(ceil(estimatedIndex)), self.photoFrameCollectionView.numberOfItems(inSection: 0) - 1)
        } else if velocity.x < 0 {
            self.currentItemIndex = max(Int(floor(estimatedIndex)), 0)
        } else {
            self.currentItemIndex = Int(round(estimatedIndex))
        }
        
        targetContentOffset.pointee = CGPoint(x: CGFloat(self.currentItemIndex) * itemWidth - self.photoFrameCollectionView.contentInset.left, y: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView === self.photoFrameCollectionView else { return .zero }
        let itemCount = self.carouselCollectionViewDataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        self.pageControl.numberOfPages = itemCount
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard collectionView === self.photoFrameCollectionView else { return UICollectionViewCell() }
        return self.carouselCollectionViewDataSource?.collectionView(collectionView, cellForItemAt: indexPath) ?? UICollectionViewCell()
    }
}
