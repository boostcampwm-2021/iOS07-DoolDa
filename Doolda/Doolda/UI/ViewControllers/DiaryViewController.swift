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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("ADD PAGE", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.setTitle("TOGGLE MODE", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private var dataSource: DataSource?
    private var dataSourceSnapshot = DataSourceSnapshot()
    private var viewModel: DiaryViewModelProtocol?
    private var cancellables: Set<AnyCancellable> = []
    
    convenience init(viewModel: DiaryViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
        self.configureCollectionViewDataSource()
    }
    
    override var prefersStatusBarHidden: Bool { return true }

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        
        self.view.addSubview(self.pageCollectionView)
        self.pageCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.addButton)
        self.addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-30)
        }
        
        self.view.addSubview(self.toggleButton)
        self.toggleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalTo(self.addButton).offset(-30)
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
                case .carousel: self.pageCollectionView.collectionViewLayout = self.horizontalFlowLayout
                case .list: self.pageCollectionView.collectionViewLayout = self.verticalFlowLayout
                }
            }
            .store(in: &self.cancellables)
        
        self.addButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.addPageButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        self.toggleButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.displayModeChangeButtonDidTap()
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
                cell.backgroundColor = .yellow
                print(pageEntity.timeStamp)
                return cell
        })
    }
    
    private func applySnapshot(pageEntities: [PageEntity]) {
        self.dataSourceSnapshot = DataSourceSnapshot()
        self.dataSourceSnapshot.appendSections([Section.pages])
        self.dataSourceSnapshot.appendItems(pageEntities)
        self.dataSource?.apply(self.dataSourceSnapshot, animatingDifferences: true)
    }
}

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
