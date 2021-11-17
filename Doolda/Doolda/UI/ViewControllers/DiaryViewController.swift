//
//  DiaryViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/04.
//

import Combine
import UIKit

import SnapKit

class DiaryViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PageEntity>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, PageEntity>
    
    enum Section {
        case pages
    }

    // MARK: - Subviews
    
    private lazy var pageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.carouselFlowLayout)
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiaryPageViewCell.self, forCellWithReuseIdentifier: DiaryPageViewCell.cellIdentifier)
        collectionView.register(
            DiaryCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DiaryCollectionViewHeader.reusableViewIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private let listFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        return flowLayout
    }()
    
    private let carouselFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        return flowLayout
    }()
    
    private lazy var displayModeToggleButton: UIButton = {
        let button = UIButton()
        button.setImage(.square, for: .normal)
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setImage(.line3HorizontalDecrease, for: .normal)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(.gearshape, for: .normal)
        return button
    }()
    
    private let transparentNavigationBarAppearance: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .clear
        appearance.configureWithTransparentBackground()
        return appearance
    }()
    
    private var headerView: UICollectionReusableView?
    
    // MARK: - Override Properties
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - Private Properties
    
    private var dataSource: DataSource?
    private var dataSourceSnapshot = DataSourceSnapshot()
    private var viewModel: DiaryViewModelProtocol?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(viewModel: DiaryViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureDataSource()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "둘다"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingsButton)
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: self.displayModeToggleButton),
            UIBarButtonItem(customView: self.filterButton)
        ]
        
        self.view.addSubview(self.pageCollectionView)
        self.pageCollectionView.snp.makeConstraints { make in
            make.topMargin.bottomMargin.leading.trailing.equalToSuperview()
        }
    }
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.filteredPageEntitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                guard let self = self else { return }
                self.applySnapshot(pageEntities: entities)
                self.scrollToMostRecentPage()
            }
            .store(in: &self.cancellables)
        
        viewModel.displayModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                guard let self = self else { return }
                switch displayMode {
                case .list:
                    self.pageCollectionView.collectionViewLayout = self.listFlowLayout
                    self.displayModeToggleButton.setImage(.square, for: .normal)
                    self.pageCollectionView.alwaysBounceHorizontal = false
                    self.pageCollectionView.alwaysBounceVertical = true
                    self.pageCollectionView.showsVerticalScrollIndicator = true
                case .carousel:
                    self.pageCollectionView.collectionViewLayout = self.carouselFlowLayout
                    self.displayModeToggleButton.setImage(.squareGrid2x2, for: .normal)
                    self.pageCollectionView.alwaysBounceHorizontal = true
                    self.pageCollectionView.alwaysBounceVertical = false
                    self.pageCollectionView.showsVerticalScrollIndicator = false
                    let pageWidth = self.view.frame.width - 32
                    let pageOffset = pageWidth + 10
                    let yOffset = self.pageCollectionView.contentOffset.y
                    let currentIndex = Int(self.pageCollectionView.contentOffset.x / pageOffset)
                    let xOffset = CGFloat(currentIndex + 1) * pageOffset - 16
                    self.pageCollectionView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
                }
            }
            .store(in: &self.cancellables)
        
        viewModel.isMyTurnPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isMyTurn in
                self?.headerView?.backgroundColor = isMyTurn ? .blue : .red
            }
            .store(in: &self.cancellables)
        
        viewModel.lastUpdatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("UPDATE COMPLETE")
            }
            .store(in: &self.cancellables)
        
        self.displayModeToggleButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.displayModeToggleButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.filterButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.filterButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.settingsButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.settingsButtonDidTap()
            }
            .store(in: &self.cancellables)
    }
    
    private func configureDataSource() {
        self.dataSource = DataSource(
            collectionView: self.pageCollectionView,
            cellProvider: { (collectionView, indexPath, pageEntity) -> DiaryPageViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DiaryPageViewCell.cellIdentifier,
                    for: indexPath
                ) as? DiaryPageViewCell else { return nil }
                cell.backgroundColor = .red
                cell.number = pageEntity.jsonPath
                return cell
        })
        
        self.dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DiaryCollectionViewHeader.reusableViewIdentifier,
                for: indexPath
            ) as? DiaryCollectionViewHeader
            self.headerView = view
            return view
        }
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.standardAppearance = transparentNavigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = transparentNavigationBarAppearance
    }
    
    // MARK: - Private Methods
    
    private func applySnapshot(pageEntities: [PageEntity], withAnimation: Bool = true) {
        self.dataSourceSnapshot = DataSourceSnapshot()
        self.dataSourceSnapshot.appendSections([Section.pages])
        self.dataSourceSnapshot.appendItems(pageEntities)
        self.dataSource?.apply(self.dataSourceSnapshot, animatingDifferences: withAnimation)
    }
    
    private func scrollToMostRecentPage() {
        guard  self.viewModel?.displayMode == .carousel else { return }
        let yOffset: CGFloat = self.pageCollectionView.contentOffset.y
        let pageWidth = self.view.frame.width - 32
        let pageOffset = pageWidth + 10 - 16
        self.pageCollectionView.setContentOffset(CGPoint(x: pageOffset, y: yOffset), animated: true)
    }
}

// MARK: - UICOllectionViewDelegateFlowLayout

extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if let displayMode = self.viewModel?.displayMode {
            switch displayMode {
            case .carousel:
                let width = self.view.frame.width - 32
                let height = width * 30.0 / 17.0
                return CGSize(width: width, height: height)
            case .list:
                let width = (self.view.frame.width - 42) / 2
                let height = width * 30.0 / 17.0
                return CGSize(width: width, height: height)
            }
        } else {
            return .zero
        }
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard scrollView == self.pageCollectionView,
              let displayMode = self.viewModel?.displayMode,
              displayMode == .carousel else { return }
        
        let pageWidth = self.view.frame.width - 32
        let pageOffset = pageWidth + 10
        let estimatedIndex = scrollView.contentOffset.x / pageOffset
        
        var actualIndex = 0
        if velocity.x > 0 {
            actualIndex = min(Int(ceil(estimatedIndex)), self.pageCollectionView.numberOfItems(inSection: 0))
        } else if velocity.x < 0 {
            actualIndex = max(Int(floor(estimatedIndex)), 0)
        } else {
            actualIndex = Int(round(estimatedIndex))
        }
        
        targetContentOffset.pointee = CGPoint(x: CGFloat(actualIndex) * pageOffset - 16, y: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = self.view.frame.width - 32
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10.0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10.0
    }
}
