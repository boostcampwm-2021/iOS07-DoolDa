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

    private let gravity = UIGravityBehavior()
    private let collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
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

    private func configureUI() {
        self.addSubview(self.bodyView)
        self.bodyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }

        let dummyStickers = [
            UIImage(named: "dochi_0"),
            UIImage(named: "dochi_1")
        ]
        dummyStickers.forEach { stickers in
            let imageView = UIImageView()
            imageView.image = stickers
            self.bodyView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.25)
                make.height.equalTo(imageView.snp.width)
            }
        }
    }

    private func bindUI() {
        self.$animating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let gravity = self?.gravity,
                      let collider = self?.collider else { return }

                if value == true {
                    self?.animator.addBehavior(gravity)
                    self?.animator.addBehavior(collider)
                } else {
                    self?.animator.removeBehavior(gravity)
                    self?.animator.removeBehavior(collider)
                }
            }
            .store(in: &self.cancellables)
    }

}
