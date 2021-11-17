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
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.text = "스티커 추가"
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
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
        let stickerPicker = StickerPickerView(
            collectionViewDelegate: self,
            collectionViewDataSource: self
        )
        return stickerPicker
    }()

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

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

    private func bindCellUI(_ cell: PackedStickerCell) {
        cell.slider.publisher(for: .valueChanged)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                if cell.slider.value >= cell.slider.maximumValue * 0.95 {
                    print("\(cell) 완료")
                }
            }
            .store(in: &self.cancellables)
    }

}

extension StickerPickerViewController: UICollectionViewDelegate {

}

extension StickerPickerViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return StickerPackType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PackedStickerCell.identifier,
            for: indexPath
        )

        if StickerPackType.allCases.count <= indexPath.section { return UICollectionViewCell() }

        guard let cell = cell as? PackedStickerCell,
              let operationQueue = OperationQueue.current,
              let stickerPack = StickerPackType.allCases[indexPath.section].rawValue else {
                  return UICollectionViewCell()
              }

        self.stickerPickerView.currentPack = indexPath.section
        self.bindCellUI(cell)
        cell.animating = false
        cell.motionManager.stopDeviceMotionUpdates()
        cell.configure(with: stickerPack.stickersUrl)
        cell.motionManager.startDeviceMotionUpdates(to: operationQueue, withHandler: cell.configureGravity)
        cell.animating = true

        return cell
    }
}
