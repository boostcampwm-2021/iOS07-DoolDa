//
//  PackedStickerCollectionViewCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import Combine
import CoreMotion
import UIKit

import Kingfisher
import SnapKit

class PackedStickerCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let identifier = "PackedStickerCollectionViewCell"

    // MARK: - Subviews

    private lazy var stickerPackBody: UIView = {
        let bodyView = UIView()
        bodyView.backgroundColor = UIColor.dooldaStickerPackBody
        return bodyView
    }()

    private lazy var stickerPackCover: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor.dooldaStickerPackCover
        return coverView
    }()

    private lazy var coverSticker: UIImageView = {
        let coverSticker = UIImageView()
        coverSticker.contentMode = .scaleAspectFit
        return coverSticker
    }()

    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.maximumTrackTintColor = UIColor.dooldaMaximumTrackTintColor
        slider.minimumTrackTintColor = UIColor.dooldaMinimumTrackTintColor
        slider.setThumbImage(UIImage.scissors, for: .normal)
        return slider
    }()

    // MARK: - Public Properties

    @Published var animating: Bool = false
    lazy var motionManager: CMMotionManager = CMMotionManager()

    // MARK: - Private Properties

    private let gravity: UIGravityBehavior = UIGravityBehavior()

    private let itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 0.4
        return behavior
    }()

    private let maximumCollisionCount: Int = 5

    private var colliders: [UICollisionBehavior] = {
        var colliders = [UICollisionBehavior]()
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        colliders.append(collider)
        return colliders
    }()

    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.stickerPackBody)
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.bindUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.backgroundColor = UIColor.dooldaStickerPackBackground

        self.addSubview(self.stickerPackBody)
        self.stickerPackBody.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        self.addSubview(self.stickerPackCover)
        self.stickerPackCover.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.stickerPackBody).multipliedBy(0.2)
        }

        self.stickerPackCover.addSubview(self.slider)
        self.slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }

        self.stickerPackCover.addSubview(self.coverSticker)
        self.coverSticker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.stickerPackCover.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalTo(self.stickerPackCover.snp.width)
        }
    }

    private func bindUI() {
        self.$animating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAnimating in
                guard let gravity = self?.gravity,
                      let colliders = self?.colliders,
                      let itemBehavior = self?.itemBehavior else { return }

                if isAnimating {
                    self?.animator.addBehavior(gravity)
                    for collider in colliders {
                        self?.animator.addBehavior(collider)
                    }
                    self?.animator.addBehavior(itemBehavior)
                } else {
                    self?.animator.removeBehavior(gravity)
                    for collider in colliders {
                        self?.animator.removeBehavior(collider)
                    }
                    self?.animator.removeBehavior(itemBehavior)
                }
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Public Methods

    func configure(with stickerPack: StickerPackEntity) {
        var widthOffset: CGFloat = 10
        var heightOffset: CGFloat = 10

        for sticker in stickerPack.stickersName {
            let stickerImage = UIImage(named: sticker)
            let stickerView = UIImageView(image: stickerImage)
            let width: CGFloat = max(self.frame.width * 0.2, 50)

            self.stickerPackBody.addSubview(stickerView)
            stickerView.frame = CGRect(x: widthOffset, y: heightOffset, width: width , height: width)

            self.gravity.addItem(stickerView)
            self.addCollider(to: stickerView)
            self.itemBehavior.addItem(stickerView)

            // FIXME: 스티커 최대 개수 제한하도록 임시 구현
            if widthOffset < 100 {
                widthOffset += 30
            } else {
                widthOffset = 10
                heightOffset += 50
            }

            if self.stickerPackBody.subviews.count >= 8 { break }
        }

        let coverStickerImage = UIImage(named: stickerPack.coverStickerName)
        self.coverSticker.image = coverStickerImage
    }

    func configureGravity(motion: CMDeviceMotion?, error: Error?) {
        guard let motion = motion else { return }
        if error != nil { print(error.debugDescription); return }

        let gravity: CMAcceleration = motion.gravity
        let gravityX = CGFloat(gravity.x)
        let gravityY = CGFloat(-gravity.y)

        self.gravity.gravityDirection = CGVector(dx: gravityX * 4, dy: gravityY * 4)
    }

    func clear() {
        self.stickerPackCover.alpha = 1
        self.slider.value = 0

        self.stickerPackBody.subviews.forEach { subview in
            subview.removeFromSuperview()
            self.gravity.removeItem(subview)
            for collider in self.colliders {
                collider.removeItem(subview)
            }
            self.itemBehavior.removeItem(subview)
        }

        self.animating = false
        self.motionManager.stopDeviceMotionUpdates()
    }

    func unpackCell() {
        self.stickerPackCover.alpha = 0
    }

    // MARK: - Private Methods

    private func addCollider(to item: UIView) {
        guard var collider = self.colliders.last else { return }

        if collider.items.count >= maximumCollisionCount {
            let newCollider = UICollisionBehavior()
            newCollider.translatesReferenceBoundsIntoBoundary = true
            self.colliders.append(newCollider)
            collider = newCollider
        }
        collider.addItem(item)
    }

}
