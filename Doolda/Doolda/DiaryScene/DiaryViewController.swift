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
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: DiaryCollectionViewCell.identifier)
        collectionView.register(
            DiaryCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DiaryCollectionViewHeader.identifier
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.backgroundView = self.pageCollectionBackgroundView
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
    
    private lazy var pageCollectionBackgroundView: DiaryBackgroundView = {
        let backgroundView = DiaryBackgroundView()
        backgroundView.image = UIImage.hedgehogFrustrated
        backgroundView.title = "표시될 페이지가 없어요!"
        return backgroundView
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
    
    private var headerView: DiaryCollectionViewHeader?
    
    // MARK: - Override Properties
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - Private Properties
    
    private var dataSource: DataSource?
    private var dataSourceSnapshot = DataSourceSnapshot()
    private var viewModel: DiaryViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []
    private var pageWidth: CGFloat { self.viewModel.displayMode == .carousel ? self.view.frame.width - 32.0 : (self.view.frame.width - 42) / 2}
    private var pageHeight: CGFloat { self.pageWidth * 30.0 / 17.0 }
    private var pageOffset: CGFloat { self.pageWidth + 10 }
    
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
        self.viewModel.diaryViewWillAppear()
        self.configureFont()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "둘다"
        
        self.navigationController?.navigationBar.barTintColor = .dooldaBackground
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
    
    private func configureFont() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        self.pageCollectionBackgroundView.titleFont = .systemFont(ofSize: 35)
        self.pageCollectionBackgroundView.subtitleFont = .systemFont(ofSize: 20)
        // FIXME: cell의 font 갱신 방법 리팩토링 필요
        self.headerView?.displayMode = self.headerView?.displayMode ?? .list
    }
    
    private func bindUI() {
        self.viewModel.filteredPageEntitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                self?.applySnapshot(pageEntities: entities)
            }
            .store(in: &self.cancellables)

        self.viewModel.displayModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                self?.updateView(with: displayMode)
            }
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.viewModel.filteredPageEntitiesPublisher, self.viewModel.displayModePublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities, displayMode in
                self?.pageCollectionBackgroundView.isHidden = !entities.isEmpty || (displayMode == .carousel)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.isMyTurnPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isMyTurn in
                self?.headerView?.isMyTurn = isMyTurn
                self?.pageCollectionBackgroundView.subtitle = "헤더를 탭해 \(isMyTurn ? "새 글을 써" : "새로고침 해")보세요!"
            }
            .store(in: &self.cancellables)

        self.viewModel.isRefreshingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRefreshing in
                self?.headerView?.isRefreshing = isRefreshing
            }
            .store(in: &self.cancellables)
        
        self.displayModeToggleButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.displayModeToggleButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.filterButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.filterButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.settingsButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.settingsButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.userPostedNewPage, object: nil)
            .sink { [weak self] _ in
                self?.scrollToPage(of: 0)
                self?.viewModel.userPostedNewPageNotificationDidReceived()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.userRequestedNewPage, object: nil)
            .sink { [weak self] _ in
                self?.scrollToPage(of: 0)
                self?.viewModel.userRequestedNewPageNotificationDidReceived()
            }
            .store(in: &self.cancellables)
    }
    
    private func configureDataSource() {
        self.dataSource = DataSource(
            collectionView: self.pageCollectionView,
            cellProvider: { [weak self] (collectionView, indexPath, pageEntity) -> DiaryCollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DiaryCollectionViewCell.identifier,
                    for: indexPath
                ) as? DiaryCollectionViewCell else { return nil }
                
                guard let viewModel = self?.viewModel else { return nil }
                cell.displayRawPage(with: viewModel.pageDidDisplay(metaData: pageEntity))
                cell.timestamp = pageEntity.createdTime
                return cell
        })
        
        self.dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DiaryCollectionViewHeader.identifier,
                for: indexPath
            ) as? DiaryCollectionViewHeader
            view?.delegate = self
            self.headerView = view
            return view
        }
    }
    
    // MARK: - Private Methods
    
    private func applySnapshot(pageEntities: [PageEntity], withAnimation: Bool = true) {
        self.dataSourceSnapshot = DataSourceSnapshot()
        self.dataSourceSnapshot.appendSections([Section.pages])
        self.dataSourceSnapshot.appendItems(pageEntities)
        self.dataSource?.apply(self.dataSourceSnapshot, animatingDifferences: withAnimation)
    }
    
    private func updateView(with displayMode: DiaryDisplayMode) {
        self.headerView?.displayMode = displayMode
        switch displayMode {
        case .list:
            self.pageCollectionView.collectionViewLayout = self.listFlowLayout
            self.displayModeToggleButton.setImage(.square, for: .normal)
            self.pageCollectionView.alwaysBounceHorizontal = false
            self.pageCollectionView.alwaysBounceVertical = true
            self.pageCollectionView.showsVerticalScrollIndicator = true
            self.navigationController?.hidesBarsOnSwipe = true
            self.title = "모아보기"
        case .carousel:
            self.pageCollectionView.collectionViewLayout = self.carouselFlowLayout
            self.displayModeToggleButton.setImage(.squareGrid2x2, for: .normal)
            self.pageCollectionView.alwaysBounceHorizontal = true
            self.pageCollectionView.alwaysBounceVertical = false
            self.pageCollectionView.showsVerticalScrollIndicator = false
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.isNavigationBarHidden = false
            self.scrollToPage(of: Int(self.pageCollectionView.contentOffset.x / self.pageOffset))
        }
    }
    
    private func scrollToPage(of index: Int) {
        guard self.viewModel.displayMode == .carousel else { return }
        let xOffset = CGFloat(min(self.viewModel.filteredEntityCount, index + 1)) * self.pageOffset - 16
        let yOffset = self.pageCollectionView.contentOffset.y
        self.setTitle(for: index)
        self.pageCollectionView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
    }
    
    private func setTitle(for index: Int) {
        if let date = self.viewModel.getDate(of: index),
           let formattedDateString = try? DateFormatter.koreanFormatter.string(from: date) {
            print(date)
            self.title = formattedDateString
        } else {
            self.title = "둘다"
        }
    }
}

// MARK: - UICOllectionViewDelegateFlowLayout

extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: self.pageWidth, height: self.pageHeight)
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard scrollView == self.pageCollectionView,
              let displayMode = self.viewModel?.displayMode,
              displayMode == .carousel else { return }
        
        let estimatedIndex = scrollView.contentOffset.x / self.pageOffset
        
        var actualIndex = 0
        if velocity.x > 0 {
            actualIndex = min(Int(ceil(estimatedIndex)), self.pageCollectionView.numberOfItems(inSection: 0))
        } else if velocity.x < 0 {
            actualIndex = max(Int(floor(estimatedIndex)), 0)
        } else {
            actualIndex = Int(round(estimatedIndex))
        }
        
        self.setTitle(for: actualIndex - 1)
        targetContentOffset.pointee = CGPoint(x: CGFloat(actualIndex) * pageOffset - 16, y: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: self.pageWidth, height: 100)
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

extension DiaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.pageDidTap(index: indexPath.item)
    }
}

extension DiaryViewController: DiaryCollectionViewHeaderDelegate {
    func refreshButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader) {
        self.viewModel?.refreshButtonDidTap()
    }
    
    func addPageButtonDidTap(_ diaryCollectionViewHeader: DiaryCollectionViewHeader) {
        self.viewModel?.addPageButtonDidTap()
    }
}

extension DiaryViewController: FilterOptionBottomSheetViewControllerDelegate {
    func applyButtonDidTap(
        _ filterOptionBottomSheetViewController: FilterOptionBottomSheetViewController,
        authorFilter: DiaryAuthorFilter,
        orderFilter: DiaryOrderFilter
    ) {
        self.viewModel.filterDidApply(author: authorFilter, orderBy: orderFilter)
    }
    
    func filterOptionDidChange(
        _ filterOptionBottomSheetViewController: FilterOptionBottomSheetViewController,
        authorFilter: DiaryAuthorFilter,
        orderFilter: DiaryOrderFilter
    ) {
        self.viewModel.filterOptionDidChange(author: authorFilter, orderBy: orderFilter)
    }
    
    func filterBottomSheetWillDismiss(_ filteredOptionBottomSheetController: FilterOptionBottomSheetViewController) {
        self.viewModel.filterBottomSheetDidDismiss()
    }
}
