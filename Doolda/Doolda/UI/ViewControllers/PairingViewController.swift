//
//  PairingViewController.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/02.
//

import UIKit

class PairingViewController: UIViewController {
    // MARK: - Subviews
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to dovemayo
        label.font = .systemFont(ofSize: 72, weight: .regular)
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        // MARK: - FIXME : change font to global font
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
    }
}
