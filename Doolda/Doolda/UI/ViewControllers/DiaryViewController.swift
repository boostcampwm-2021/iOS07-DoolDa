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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.horizontalFlowLayout)
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiaryPageViewCell.self, forCellWithReuseIdentifier: DiaryPageViewCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        return collectionView
    }()
    
    private let horizontalFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        return flowLayout
    }()
    
    private let verticalFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
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
        self.bindUI()
        self.configureCollectionViewDataSource()
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
            make.edges.equalToSuperview()
        }
    }
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.filteredPageEntitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                self?.applySnapshot(pageEntities: entities)
            }
            .store(in: &self.cancellables)
        
        viewModel.displayModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayMode in
                guard let self = self else { return }
                switch displayMode {
                case .carousel:
                    self.pageCollectionView.collectionViewLayout = self.horizontalFlowLayout
                    self.displayModeToggleButton.setImage(.squareGrid2x2, for: .normal)
                case .list:
                    self.pageCollectionView.collectionViewLayout = self.verticalFlowLayout
                    self.displayModeToggleButton.setImage(.square, for: .normal)
                }
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
    
    private func configureCollectionViewDataSource() {
        self.dataSource = DataSource(
            collectionView: self.pageCollectionView,
            cellProvider: { (collectionView, indexPath, pageEntity) -> DiaryPageViewCell? in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: DiaryPageViewCell.cellIdentifier,
                    for: indexPath
                ) as? DiaryPageViewCell else { return nil }
                cell.backgroundColor = .red
                return cell
        })
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.standardAppearance = transparentNavigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = transparentNavigationBarAppearance
    }
    
    // MARK: - Private Methods
    
    private func applySnapshot(pageEntities: [PageEntity]) {
        self.dataSourceSnapshot = DataSourceSnapshot()
        self.dataSourceSnapshot.appendSections([Section.pages])
        self.dataSourceSnapshot.appendItems(pageEntities)
        self.dataSource?.apply(self.dataSourceSnapshot, animatingDifferences: true)
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
}
