//
//  FontColorCollectionViewCell.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/22.
//

import UIKit

class FontColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let identifier = "FontColorCollectionViewCell"
    
    // MARK: - Subviews
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.cornerRadius = 15
        return view
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }
    
    // MARK: - Helpers
    
    func configure(with color: UIColor) {
        self.colorView.backgroundColor = color
    }
    
    private func configureUI() {
        self.addSubview(self.colorView)
        self.colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
