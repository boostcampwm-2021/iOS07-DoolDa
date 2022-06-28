//
//  StickerPickerBottomSheetViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/15.
//

import Combine
import CoreMotion
import UIKit

import SnapKit

protocol StickerPickerBottomSheetViewControllerDelegate: AnyObject {
    func stickerDidSelected(_ stickerComponentEntity: StickerComponentEntity)
}

class StickerPickerBottomSheetViewController: BottomSheetViewController {

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
        return StickerPickerView(
            collectionViewDelegate: self,
            collectionViewDataSource: self,
            collectionViewLayout: self.createStickerPickerCompositionalLayout()
        )
    }()

    // MARK: - Private Properties

    private var viewModel: StickerPickerBottomSheetViewModelProtocol!
    private weak var delegate: StickerPickerBottomSheetViewControllerDelegate?
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    private var cancellables = [Int: AnyCancellable]()

    // MARK: - Initializers

    convenience init(
        stickerPickerBottomSheetViewModel: StickerPickerBottomSheetViewModelProtocol,
        delegate: StickerPickerBottomSheetViewControllerDelegate?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = stickerPickerBottomSheetViewModel
        self.delegate = delegate
    }

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureGenerator()
        self.bindUI()
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
            make.leading.trailing.equalTo(self.body)
            make.bottom.equalTo(self.body.snp.bottom).offset(-13)
        }
    }

    private func configureGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        self.feedbackGenerator?.prepare()
    }

    private func bindUI() {
        let publihser = self.closeButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        self.cancellables[-1] = publihser
    }

    private func bindCellUI(_ cell: PackedStickerCollectionViewCell, at indexPath: IndexPath) {
        let publisher = cell.slider.publisher(for: .valueChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if Int(cell.slider.value) % 3 == 1 {
                    self?.feedbackGenerator?.impactOccurred()
                }

                if cell.slider.value == cell.slider.maximumValue {
                    guard let stickerPack = self?.viewModel.getStickerPackEntity(at: indexPath.section) else { return }

                    stickerPack.isUnpacked = true
                    self?.feedbackGenerator?.impactOccurred()
                    UIView.animate(withDuration: 1.0, animations: { cell.unpackCell() }) { [weak self] _ in
                        UIView.animate(withDuration: 0.5, animations: { cell.alpha = 0 }) { [weak self] _ in
                            self?.stickerPickerView.collectionView.collectionViewLayout.invalidateLayout()
                            UIView.animate(withDuration: 0.5, animations: { self?.stickerPickerView.collectionView.reloadData()
                            })
                        }
                    }
                    self?.cancellables[indexPath.section]?.cancel()
                }
            }
        self.cancellables[indexPath.section] = publisher
    }

    // MARK: - Private Methods

    private func createStickerPickerCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let stickerPack = self.viewModel.getStickerPackEntity(at: sectionIndex) else { return nil }

            if stickerPack.isUnpacked { return self.createUnPackedStickerLayoutSection(in: environment) }
            return self.createPackedStickerLayoutSection(in: environment)
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        layout.configuration = config
        return layout
    }

    private func createPackedStickerLayoutSection(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let height = environment.container.contentSize.height * 0.75
        let width = height * 0.85
        let widthInset = (environment.container.contentSize.width - width) / 2
        let heightInset = (environment.container.contentSize.height - height) / 2

        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = .init(top: heightInset/2, leading: widthInset, bottom: heightInset, trailing: widthInset)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            subitems: [item]
        )

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(16))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [footer]
        return section
    }

    private func createUnPackedStickerLayoutSection(in environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1))
        )
        item.contentInsets = .init(top: 0, leading: 3, bottom: 0, trailing: 3)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)),
            subitems: [item]
        )
        group.contentInsets = .init(top: 6, leading: 8, bottom: 10, trailing: 8)

        let anchor = NSCollectionLayoutAnchor(edges: [.bottom], absoluteOffset: CGPoint(x: 0, y: 16))
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(16))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            containerAnchor: anchor
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [footer]
        return section
    }

}

extension StickerPickerBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PackedStickerCollectionViewCell,
              let operationQueue = OperationQueue.current,
              let stickerPack = self.viewModel.getStickerPackEntity(at: indexPath.section) else { return }

        self.bindCellUI(cell, at: indexPath)
        cell.clear()
        cell.configure(with: stickerPack)
        cell.motionManager.startDeviceMotionUpdates(to: operationQueue, withHandler: cell.configureGravity)
        cell.animating = true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _ = collectionView.cellForItem(at: indexPath) as? UnpackedStickerCollectionViewCell,
              let stickerComponentEntity = self.viewModel.stickerDidSelect(at: indexPath) else { return }
        self.delegate?.stickerDidSelected(stickerComponentEntity)
        self.dismiss(animated: true, completion: nil)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        let currentSection = Int(round(CGFloat(collectionView.numberOfSections) * targetContentOffset.pointee.x / scrollView.contentSize.width))
        self.stickerPickerView.currentPack = currentSection
    }
}

extension StickerPickerBottomSheetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.getStickerPacks().count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let stickerPack = self.viewModel.getStickerPackEntity(at: section) else { return 0 }
        if stickerPack.isUnpacked { return stickerPack.stickerCount }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let stickerPack = self.viewModel.getStickerPackEntity(at: indexPath.section) else {
            return UICollectionViewCell()
        }

        if !stickerPack.isUnpacked {
            return collectionView.dequeueReusableCell(withReuseIdentifier: PackedStickerCollectionViewCell.identifier, for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UnpackedStickerCollectionViewCell.identifier, for: indexPath)
        guard let cell = cell as? UnpackedStickerCollectionViewCell,
              let stickerName = self.viewModel.getStickerName(at: indexPath),
              let stickerImage = UIImage(named: stickerName) else { return cell }

        cell.configure(with: stickerImage)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: StickerPickerCollectionViewFooter.identifier,
            for: indexPath
        ) as? StickerPickerCollectionViewFooter,
              let stickerPack = self.viewModel.getStickerPackEntity(at: indexPath.section) else { return UICollectionReusableView() }

        footerView.configureStickerPackTilte(with: stickerPack.displayName)
        return footerView
    }
}
