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

    private lazy var bodyView: UIView = {
        let bodyView = UIView()
        bodyView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        return bodyView
    }()

    private lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
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

    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.bodyView)
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

    func configure(with stickerPack: StickerPackEntity) {
        self.bodyView.subviews.forEach { subview in
            subview.removeFromSuperview()
            self.gravity.removeItem(subview)
            self.collider.removeItem(subview)
            self.itemBehavior.removeItem(subview)
        }

        let stickers = stickerPack.stickersUrl
        var offset: CGFloat = 10
        for url in stickers {
            guard let stickerImage = try? UIImage(data: Data(contentsOf: url)) else { continue }
            let stickerView = UIImageView(image: stickerImage)
            let ratio = stickerImage.size.height / stickerImage.size.width
            var width: CGFloat = self.frame.width * 0.2
            if width == 0 { width = 50 }

            self.bodyView.addSubview(stickerView)
            stickerView.frame = CGRect(x: offset, y: offset, width: width , height: width * ratio)

            self.gravity.addItem(stickerView)
            self.collider.addItem(stickerView)
            self.itemBehavior.addItem(stickerView)

            offset += 20
        }

        guard let coverImage = try? UIImage(data: Data(contentsOf: stickerPack.coverUrl)) else { return }
        self.coverSticker.image = coverImage
    }

    // MARK: - Public Methods

    func configureGravity(motion: CMDeviceMotion?, error: Error?) {
        guard let motion = motion else { return }
        if error != nil { print(error.debugDescription); return }

        let gravity: CMAcceleration = motion.gravity
        let gravityX = CGFloat(gravity.x)
        let gravityY = CGFloat(-gravity.y)

        self.gravity.gravityDirection = CGVector(dx: gravityX*2.5, dy: gravityY*2.5)
    }

    private func configureUI() {
        self.backgroundColor = .white

        self.addSubview(self.bodyView)
        self.bodyView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        self.addSubview(self.coverView)
        self.coverView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.bodyView).multipliedBy(0.2)
        }

        self.coverView.addSubview(self.slider)
        self.slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }

        self.coverView.addSubview(self.coverSticker)
        self.coverSticker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.coverView.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.25)
            make.height.equalTo(self.coverView.snp.width)
        }
    }

    private func bindUI() {
        self.$animating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let gravity = self?.gravity,
                      let collider = self?.collider,
                      let itemBehavior = self?.itemBehavior else { return }

                if value == true {
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
