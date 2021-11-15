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
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiaryPageViewCell.self, forCellWithReuseIdentifier: DiaryPageViewCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var testButton: UIButton = {
        let button = UIButton()
        button.setTitle("TOUCH ME", for: .normal)
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

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        
        self.view.addSubview(self.pageCollectionView)
        self.pageCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.testButton)
        self.testButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-30)
        }
    }
    
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.filteredPageEntities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                self?.applySnapshot(pageEntities: entities)
            }
            .store(in: &self.cancellables)
        
        self.testButton.publisher(for: .touchUpInside)
            .sink { _ in
                viewModel.addPageButtonDidTap()
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
