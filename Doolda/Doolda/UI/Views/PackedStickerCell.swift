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

    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.maximumTrackTintColor = .lightGray
        slider.minimumTrackTintColor = .darkGray
        slider.setThumbImage(UIImage(systemName: "scissors"), for: .normal)
        return slider
    }()

    // MARK: - Public Properties

    @Published var animating: Bool = false

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

    func configure(with stickers: [URL]) {
        self.bodyView.subviews.forEach { subview in
            subview.removeFromSuperview()
            self.gravity.removeItem(subview)
            self.collider.removeItem(subview)
            self.itemBehavior.removeItem(subview)
        }

        var leadingOffset: CGFloat = 10
        for url in stickers {
            guard let stickerImage = try? UIImage(data: Data(contentsOf: url)) else { continue }
            let stickerView = UIImageView(image: stickerImage)
            let ratio = stickerImage.size.height / stickerImage.size.width
            let width = self.bodyView.frame.width * 0.2

            stickerView.frame = CGRect(x: leadingOffset, y: leadingOffset, width: width , height: width * ratio)

            self.bodyView.addSubview(stickerView)
            stickerView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(leadingOffset)
                make.width.equalToSuperview().multipliedBy(0.2)
                make.height.equalTo(stickerView.snp.width).multipliedBy(ratio)
            }

            self.gravity.addItem(stickerView)
            self.collider.addItem(stickerView)
            self.itemBehavior.addItem(stickerView)

            leadingOffset += 20
        }
    }

    // FIXME: StickerEntity 오류 수정되면 없어질 메소드
    func configure(with stickers: [UIImage]) {
        self.bodyView.subviews.forEach { subview in
            subview.removeFromSuperview()
            self.gravity.removeItem(subview)
            self.collider.removeItem(subview)
            self.itemBehavior.removeItem(subview)
        }

        var leadingOffset: CGFloat = 10
        for stickerImage in stickers {
            let stickerView = UIImageView(image: stickerImage)
            let ratio = stickerImage.size.height / stickerImage.size.width
            let width = self.bodyView.frame.width * 0.2

            stickerView.frame = CGRect(x: leadingOffset, y: leadingOffset, width: width , height: width * ratio)

            self.bodyView.addSubview(stickerView)
            stickerView.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(leadingOffset)
                make.width.equalToSuperview().multipliedBy(0.2)
                make.height.equalTo(stickerView.snp.width).multipliedBy(ratio)
            }
     
            self.gravity.addItem(stickerView)
            self.collider.addItem(stickerView)
            self.itemBehavior.addItem(stickerView)

            leadingOffset += 20
        }
    }

    func configureGravity(motion: CMDeviceMotion?, error: Error?) {
        guard let motion = motion,
              let _ = error else { return }
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
            make.top.equalToSuperview().multipliedBy(0.5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
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
