//
//  BackgroundTypePickerViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/14.
//

import Combine
import UIKit

protocol BackgroundTypePickerViewControllerDelegate: AnyObject {
    func backgroundTypeDidSelect(_ backgroundType: BackgroundType)
}

final class BackgroundTypePickerViewController: BottomSheetViewController {
    
    // MARK: - Static Properties
    
    static let identifier = "backgroundTypeCellIdentifier"
    
    // MARK: - Subviews
    
    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
        label.text = "배경지"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.xmark, for: .normal)
        return button
    }()
    
    private lazy var topStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                bottomSheetTitle,
                closeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var backgroundTypeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 30
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Self.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private weak var delegate: BackgroundTypePickerViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(delegate: BackgroundTypePickerViewControllerDelegate?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.detent = .smallLarge
        self.body.backgroundColor = .dooldaBackground
        
        self.body.addSubview(self.topStack)
        self.topStack.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.body.addSubview(self.backgroundTypeCollectionView)
        self.backgroundTypeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topStack.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func bindUI() {
        self.closeButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
    }
}

extension BackgroundTypePickerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let insetX = collectionView.contentInset.left + collectionView.contentInset.right
        let cellSize = (collectionView.bounds.width - layout.minimumInteritemSpacing - insetX) / 2
        return CGSize(width: cellSize, height: cellSize * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackgroundType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.identifier, for: indexPath)
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.backgroundColor = UIColor(cgColor: BackgroundType.allCases[indexPath.item].rawValue)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.backgroundTypeDidSelect(BackgroundType.allCases[indexPath.item])
        self.dismiss(animated: true, completion: nil)
    }
}
