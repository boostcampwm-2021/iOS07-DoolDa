//
//  PackedStickerCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import Combine
import CoreMotion
import UIKit

import SnapKit

class PackedStickerCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let identifier = "PackedStickerCell"

    // MARK: - Subviews

    private lazy var stickerPackBody: UIView = {
        let bodyView = UIView()
        bodyView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        return bodyView
    }()

    private lazy var stickerPackCover: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        return coverView
    }()

    private lazy var coverSealingSticker: UIImageView = {
        let coverSticker = UIImageView()
        coverSticker.contentMode = .scaleAspectFit
        return coverSticker
    }()

    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.maximumTrackTintColor = .systemGray5
        slider.minimumTrackTintColor = .systemGray4
        slider.setThumbImage(UIImage(systemName: "scissors"), for: .normal)
        return slider
    }()

    // MARK: - Public Properties

    @Published var animating: Bool = false
    lazy var motionManager: CMMotionManager = CMMotionManager()

    // MARK: - Private Properties

    private let gravity: UIGravityBehavior = UIGravityBehavior()

    private let collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()

    private let itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 0.4
        return behavior
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

    func clear() {
        self.slider.value = 0

        self.stickerPackBody.subviews.forEach { subview in
            subview.removeFromSuperview()
            self.gravity.removeItem(subview)
            self.collider.removeItem(subview)
            self.itemBehavior.removeItem(subview)
        }

        self.animating = false
        self.motionManager.stopDeviceMotionUpdates()
    }

    func configure(with stickerPack: StickerPackEntity) {
        let stickers = stickerPack.stickersUrl
        var offset: CGFloat = 10
        for url in stickers {
            guard let stickerImage = try? UIImage(data: Data(contentsOf: url)) else { continue }
            let stickerView = UIImageView(image: stickerImage)
            let ratio = stickerImage.size.height / stickerImage.size.width
            let width: CGFloat = max(self.frame.width * 0.2, 50)

            self.stickerPackBody.addSubview(stickerView)
            stickerView.frame = CGRect(x: offset, y: offset, width: width , height: width * ratio)

            self.gravity.addItem(stickerView)
            self.collider.addItem(stickerView)
            self.itemBehavior.addItem(stickerView)

            offset += 20
        }

        guard let coverImage = try? UIImage(data: Data(contentsOf: stickerPack.sealingImageUrl)) else { return }
        self.coverSealingSticker.image = coverImage
    }

    // MARK: - Public Methods

    func configureGravity(motion: CMDeviceMotion?, error: Error?) {
        guard let motion = motion else { return }
        if error != nil { print(error.debugDescription); return }

        let gravity: CMAcceleration = motion.gravity
        let gravityX = CGFloat(gravity.x)
        let gravityY = CGFloat(-gravity.y)

        self.gravity.gravityDirection = CGVector(dx: gravityX * 2.5, dy: gravityY * 2.5)
    }

    private func configureUI() {
        self.backgroundColor = .white

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

        self.stickerPackCover.addSubview(self.coverSealingSticker)
        self.coverSealingSticker.snp.makeConstraints { make in
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
                      let collider = self?.collider,
                      let itemBehavior = self?.itemBehavior else { return }

                if isAnimating {
                    self?.animator.addBehavior(gravity)
                    self?.animator.addBehavior(collider)
                    self?.animator.addBehavior(itemBehavior)
                } else {
                    self?.animator.removeBehavior(gravity)
                    self?.animator.removeBehavior(collider)
                    self?.animator.removeBehavior(itemBehavior)
                }
            }
            .store(in: &self.cancellables)
    }

}
