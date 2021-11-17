//
//  TextInputViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import Combine
import UIKit

protocol TextInputViewControllerDelegate: AnyObject {
    func textInputDidEndEditing(_ textComponentEntity: TextComponentEntity)
}

class TextInputViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: TextInputViewModel?
    private weak var delegate: TextInputViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(
        textInputViewModel: TextInputViewModel,
        delegate: TextInputViewControllerDelegate?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = textInputViewModel
        self.delegate = delegate
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configureCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureCommon()
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
    }
    
    private func bindUI() {
        self.view.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: false)
            }.store(in: &self.cancellables)
    }
    
    // MARK: - Helpers
    
    private func configureCommon() {
        self.modalPresentationStyle = .overFullScreen
    }
    
    private func configureUI() {
        self.view.backgroundColor = .black
        self.view.alpha = 0.3
    }
}
