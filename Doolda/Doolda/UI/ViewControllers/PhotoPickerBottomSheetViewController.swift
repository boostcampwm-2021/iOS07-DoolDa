//
//  PhotoPickerBottomSheetViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

final class PhotoPickerBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Subviews
    
    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.text = "사진 추가"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
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
    
    private lazy var contentFrame: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var framePickerViewController: FramePickerViewController = {
        let viewController = FramePickerViewController(framePickerViewControllerDelegate: self)
        return viewController
    }()
    
    private lazy var photoPickerViewController: PhotoPickerViewController = {
        let viewController = PhotoPickerViewController()
        return viewController
    }()
    
    private lazy var nextButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .dooldaLabel
        configuration.baseBackgroundColor = .dooldaHighlighted
        
        var container = AttributeContainer()
        container.font = UIFont(name: "Dovemayo", size: 16)
        configuration.attributedTitle = AttributedString("다음", attributes: container)
        return UIButton(configuration: configuration)
    }()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var currentContentViewController: UIViewController?
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindUI()
        
        setChildViewController(child: self.framePickerViewController)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.detent = .smallLarge
        self.body.backgroundColor = .dooldaBackground
        
        self.body.addSubview(self.topStack)
        self.topStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        self.body.addSubview(self.contentFrame)
        self.contentFrame.snp.makeConstraints { make in
            make.top.equalTo(self.topStack.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self.body)
        }
        
        self.body.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
            make.top.equalTo(self.contentFrame.snp.bottom).offset(10).priority(.low)
        }
    }
    
    private func bindUI() {
        self.nextButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.setChildViewController(child: self.photoPickerViewController)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Method
    
    private func setChildViewController(child viewController: UIViewController) {
        self.currentContentViewController?.didMove(toParent: nil)
        self.currentContentViewController?.view.removeFromSuperview()
        self.currentContentViewController?.view.snp.removeConstraints()
        self.currentContentViewController?.removeFromParent()
        
        self.addChild(viewController)
        self.contentFrame.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
        self.currentContentViewController = viewController
    }
}

extension PhotoPickerBottomSheetViewController: FramePickerViewControllerDelegate {
    func photoFrameDidChange(_ photoFrameType: PhotoFrameType) {
        // FIXME : 
    }
}
