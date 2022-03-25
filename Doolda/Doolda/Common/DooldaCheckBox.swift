//
//  DooldaCheckBox.swift
//  Doolda
//
//  Created by 정지승 on 2022/03/24.
//

import Combine
import UIKit

import SnapKit

final class DooldaCheckBox: UIView {
    
    // MARK: - Subviews
    
    private lazy var imageBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.layer.cornerRadius = 4
        backgroundView.clipsToBounds = true
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.gray.cgColor
        return backgroundView
    }()
    
    private lazy var checkImage: UIImageView = UIImageView()
    
    private lazy var textLabel: UILabel = UILabel()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Properties
    
    @Published var value: Bool = false {
        didSet {
            self.checkImage.image = UIImage(systemName: self.value ? "checkmark" : "")
        }
    }
    
    var text: String? {
        get {
            self.textLabel.text
        }
        
        set {
            self.textLabel.text = newValue
        }
    }
    
    var spacing: CGFloat = 10.0 {
        didSet {
            self.textLabel.snp.updateConstraints({ make in
                make.leading.equalTo(self.checkImage.snp.trailing).offset(self.spacing)
            })
        }
    }
    
    var textColor: UIColor? = .black {
        didSet {
            self.textLabel.textColor = textColor
        }
    }
    
    var font: UIFont? {
        didSet {
            self.textLabel.font = self.font
        }
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: .zero)
        configureUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.addSubview(self.imageBackgroundView)
        self.imageBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(self.snp.height)
            make.centerY.leading.equalToSuperview()
        }
        
        self.imageBackgroundView.addSubview(self.checkImage)
        self.checkImage.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(3)
            make.bottom.right.equalToSuperview().offset(-3)
        }
        
        self.addSubview(self.textLabel)
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.checkImage.snp.trailing).offset(self.spacing)
            make.centerY.trailing.equalToSuperview()
        }
    }
    
    private func bindUI() {
        self.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                self?.toggle()
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Public Methods
    
    func toggle() {
        self.value.toggle()
    }
}
