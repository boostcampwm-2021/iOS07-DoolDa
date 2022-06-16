//
//  DooldaButton.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import Combine
import UIKit

class DooldaButton: UIButton {

    // Private Properties

    private var cancellables: Set<AnyCancellable> = []
    private lazy var hapticGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        return generator
    }()

    // Override Properties

    override var isEnabled: Bool {
        didSet { self.alpha = self.isEnabled ? 1.0 : 0.5 }
    }

    // Initializers

    init() {
        super.init(frame: .zero)
        self.bindUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.bindUI()
    }

    // LifeCycle Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }

    // Private Methods

    private func bindUI() {
        self.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.hapticGenerator.prepare()
                self?.hapticGenerator.impactOccurred()
            }
            .store(in: &self.cancellables)
    }
}
