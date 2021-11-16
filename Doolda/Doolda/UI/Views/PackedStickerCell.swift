//
//  PackedStickerCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/16.
//

import Combine
import UIKit

import SnapKit

class PackedStickerCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let identifier = "PackedStickerCell"

    // MARK: - Subviews

    private lazy var bodyView: UIView = {
        let bodyView = UIView()
        bodyView.backgroundColor = UIColor(cgColor: CGColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.7))
        return bodyView
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
        }

        var leadingOffset = 0
        for url in stickers {
            guard let stickerImage = try? UIImage(data: Data(contentsOf: url)) else { continue }
            let stickerView = UIImageView(image: stickerImage)
            let ratio = stickerImage.size.height / stickerImage.size.width

            self.bodyView.addSubview(stickerView)
            stickerView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(leadingOffset)
                make.width.equalToSuperview().multipliedBy(0.2)
                make.height.equalTo(stickerView.snp.width).multipliedBy(ratio)
            }

            self.gravity.addItem(stickerView)
            self.collider.addItem(stickerView)
            self.itemBehavior.addItem(stickerView)

            leadingOffset += 20
        }
    }
    

    private func configureUI() {
        self.addSubview(self.bodyView)
        self.bodyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
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
