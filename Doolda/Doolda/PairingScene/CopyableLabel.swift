//
//  CopyableLabel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import Combine
import UIKit

class CopyableLabel: UILabel {
    
    // MARK: - Private Properties
    
    private let menu: UIMenuController = UIMenuController.shared
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Override Methods
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = self.text
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
    
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
        self.isUserInteractionEnabled = true
    }
    
    private func bindUI() {
        self.publisher(for: UILongPressGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.becomeFirstResponder()
                self.menu.showMenu(from: self, rect: self.bounds)
            }
            .store(in: &cancellables)
    }
}
