//
//  StickerPickerViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/15.
//

import Combine
import CoreMotion
import UIKit

import SnapKit

class StickerPickerViewController: BottomSheetViewController {

    // MARK: - Subviews

    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
        label.text = "스티커 추가"
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.xmark, for: .normal)
        button.sizeToFit()
        return button
    }()

    private lazy var topStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.bottomSheetTitle,
                self.closeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var stickerPickerView: StickerPickerView = {
        return StickerPickerView(collectionViewDelegate: self, collectionViewDataSource: self)
    }()

    // MARK: - Private Properties

    private var cancellables = [Int: AnyCancellable]()

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.detent = .medium
        self.body.backgroundColor = .dooldaBackground

        self.body.addSubview(self.topStack)
        self.topStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        self.body.addSubview(self.stickerPickerView)
        self.stickerPickerView.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func bindCellUI(_ cell: PackedStickerCell, at indexPath: IndexPath) {
        let publisher = cell.slider.publisher(for: .valueChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if cell.slider.value >= cell.slider.maximumValue * 0.95 {
                    // FIXME: PackedStickerCell이 구현되면 수정할 예정
                    print("\(indexPath.section) 완료")

                    guard let stickerPack = self?.stickerPackMapper(at: indexPath.section) else { return }
                    //stickerPack.setIsUnpacked(true)

                }
            }
        self.cancellables[indexPath.section] = publisher
    }

    // MARK: - Private Methods

    private func createStickerPickerCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let stickerPack = self.stickerPackMapper(at: sectionIndex) else { return nil }

            if stickerPack.isUnpacked { return self.createUnPackedStickerLayoutSection(in: environment) }
            return self.createPackedStickerLayoutSection(in: environment)
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }

    private func createPackedStickerLayoutSection(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let width = environment.container.contentSize.width * 0.45
        let height = width * 1.25
        let widthInset = (environment.container.contentSize.width - width) / 2
        let heightInset = (environment.container.contentSize.height - height) / 2

        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = .init(top: heightInset, leading: widthInset, bottom: heightInset, trailing: widthInset)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
//        let footerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
//        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerItemSize, elementKind: "footer", alignment: .bottom)
//        section.boundarySupplementaryItems = [footerItem]

        return section
    }

    private func createUnPackedStickerLayoutSection(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    private func stickerPackMapper(at section: Int) -> StickerPackEntity? {
        if StickerPackType.allCases.count <= section { return nil }
        return StickerPackType.allCases[section].rawValue
    }

    private func stickerUrlMapper(at indexPath: IndexPath) -> URL? {
        guard let stickerPack = self.stickerPackMapper(at: indexPath.section) else { return nil }
        if stickerPack.stickersUrl.count <= indexPath.item { return nil }
        return stickerPack.stickersUrl[indexPath.item]
    }

}

extension StickerPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.stickerPickerView.currentPack = indexPath.section

        guard let cell = cell as? PackedStickerCell,
              let operationQueue = OperationQueue.current,
              let stickerPack = self.stickerPackMapper(at: indexPath.section) else { return }

        self.bindCellUI(cell, at: indexPath)
        cell.clear()
        cell.configure(with: stickerPack)
        cell.motionManager.startDeviceMotionUpdates(to: operationQueue, withHandler: cell.configureGravity)
        cell.animating = true
    }

}

extension StickerPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return StickerPackType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let stickerPack = self.stickerPackMapper(at: section) else { return 0 }
        if stickerPack.isUnpacked { return stickerPack.stickersUrl.count }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let stickerPack = self.stickerPackMapper(at: indexPath.section) else { return UICollectionViewCell() }

        if !stickerPack.isUnpacked {
            return collectionView.dequeueReusableCell(withReuseIdentifier: PackedStickerCell.identifier, for: indexPath)
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnpackedStickerCell.identifier, for: indexPath) as? UnpackedStickerCell,
              let stickerUrl = self.stickerUrlMapper(at: indexPath) else { return UICollectionViewCell() }

        cell.configure(with: stickerUrl)
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind != UICollectionView.elementKindSectionFooter { return UICollectionReusableView() }
//        
//        return UICollectionReusableView()
//    }
}
