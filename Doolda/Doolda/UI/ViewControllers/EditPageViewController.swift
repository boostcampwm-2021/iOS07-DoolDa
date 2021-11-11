//
//  EditPageViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

class EditPageViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
    private lazy var cancelButton: UIButton = {
        var button = UIButton()
        button.setImage(.xmark, for: .normal)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        var button = UIButton()
        button.setImage(.checkmark, for: .normal)
        return button
    }()
    
    private lazy var pageView: UIView = {
        var view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var addPhotoComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.photo, for: .normal)
        return button
    }()
    
    private lazy var addTextComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.textformat, for: .normal)
        return button
    }()
    
    private lazy var addStickerComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.sticker, for: .normal)
        return button
    }()
    
    private lazy var changeBackgroundTypeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.background, for: .normal)
        return button
    }()
    
    private lazy var componentsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.addPhotoComponentButton,
                self.addTextComponentButton,
                self.addStickerComponentButton,
                self.changeBackgroundTypeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: EditPageViewModelProtocol?
    private var componentViewDictionary: [ComponentEntity: ComponentView] = [:]
    
    private var widthRatioFromAbsolute: CGFloat {
        return self.pageView.frame.size.width / 1700.0
    }
    
    private var heightRatioFromAbsolute: CGFloat {
        return self.pageView.frame.size.height / 3000.0
    }
    
    private var scale: CGFloat = 0
    private var savedScale: CGFloat = 1
    private var deltaAngle: Float = 0
    private var initialDistance: CGFloat = 0
    private var initialAngle: CGFloat = 0
    
    // MARK: - Initializers
    
    convenience init(viewModel: EditPageViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
        self.bindViewModel()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Dovemayo", size: 17) as Any
        ]
        self.title = "새 페이지"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.cancelButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.saveButton)

        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.centerY.equalToSuperview().priority(.low)
        }
        
        self.contentView.addSubview(self.pageView)
        self.pageView.isUserInteractionEnabled = true
        self.pageView.clipsToBounds = true
        self.pageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
            make.height.equalTo(self.pageView.snp.width).multipliedBy(30.0/17.0)
        }
        
        self.contentView.addSubview(self.componentsStackView)
        self.componentsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.pageView)
            make.top.equalTo(self.pageView.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-28)
            make.width.equalTo(135)
        }
    }
    
    private func bindUI() {
        self.cancelButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController.cancelEditPageAlert { _ in
                    self.viewModel?.cancelEditingPageButtonDidTap()
                }
                self.present(alert, animated: true)
            }.store(in: &self.cancellables)
        
        self.saveButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let alert = UIAlertController.saveEditPageAlert { _ in
                    self.viewModel?.saveEditingPageButtonDidTap()
                }
                self.present(alert, animated: true)
            }.store(in: &self.cancellables)
        
        self.pageView.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] gesture in
                guard let self = self else { return }
                let touchCGPoint = gesture.location(in: self.pageView)
                self.viewModel?.canvasDidTap(at: self.computePointToAbsolute(at: touchCGPoint))
            }.store(in: &self.cancellables)
        
        self.addPhotoComponentButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel?.photoComponentAddButtonDidTap()
            }.store(in: &self.cancellables)
        
        self.changeBackgroundTypeButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel?.backgroundTypeButtonDidTap()
            }.store(in: &self.cancellables)
    }
    
    private func bindViewModel() {
        self.viewModel?.selectedComponentPublisher
            .sink { [weak self] componentEntity in
                guard let self = self else { return }
                self.componentViewDictionary.values.forEach { $0.isSelected = false }
                guard let componentEntity = componentEntity,
                      let componentView = self.componentViewDictionary[componentEntity] else { return }
                componentView.isSelected = true
                let computedCGRect = CGRect(
                    origin: self.computePointFromAbsolute(at: componentEntity.origin),
                    size: self.computeSizeFromAbsolute(with: componentEntity.size)
                )
                componentView.layer.frame = computedCGRect
                
                var transform = CGAffineTransform.identity
                transform = transform.rotated(by: CGFloat(-componentEntity.angle))
                componentView.transform = transform
            }.store(in: &self.cancellables)
        
        self.viewModel?.componentsPublisher
            .sink { [weak self] componenets in
                guard let self = self else { return }
                self.componentViewDictionary.forEach { key, value in
                    value.removeFromSuperview()
                    self.componentViewDictionary[key] = nil
                }
                for componentEntity in componenets {
                    let computedCGRect = CGRect(
                        origin: self.computePointFromAbsolute(at: componentEntity.origin),
                        size: self.computeSizeFromAbsolute(with: componentEntity.size)
                    )
                    let contentView = UIView(frame: computedCGRect)
                    let componentView = ComponentView(component: contentView, delegate: self)
                    self.componentViewDictionary[componentEntity] = componentView
                }
            }.store(in: &self.cancellables)
        
        self.viewModel?.backgroundPublisher
            .sink { backgroundType in
                self.pageView.backgroundColor = UIColor(cgColor: backgroundType.rawValue)
            }.store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods
    private func computePointToAbsolute(at point: CGPoint) -> CGPoint {
        let computedX = point.x / self.widthRatioFromAbsolute
        let computedY = point.y / self.heightRatioFromAbsolute
        return CGPoint(x: computedX, y: computedY)
    }
    
    private func computePointFromAbsolute(at point: CGPoint) -> CGPoint {
        let computedX = point.x * self.widthRatioFromAbsolute
        let computedY = point.y * self.heightRatioFromAbsolute
        return CGPoint(x: computedX, y: computedY)
    }
    
    private func computeSizeFromAbsolute(with size: CGSize) -> CGSize {
        let computedWidth =  size.width  * self.widthRatioFromAbsolute
        let computedHeight = size.height  * self.widthRatioFromAbsolute
        return CGSize(width: computedWidth, height: computedHeight)
    }
}

extension EditPageViewController: ComponentViewDelegate {
    
    func leftTopControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentBringForwardControlDidTap()
    }
    
    func leftBottomControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentSendBackwardControlDidTap()
    }
    
    func rightTopControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentRemoveControlDidTap()
    }
    
    func rightBottomcontrolDidPan(_ componentView: ComponentView, with gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        let center = componentView.center

        let xDifference = (center.x - touchLocation.x)
        let yDifference = (center.y - touchLocation.y)
        let distance = sqrt(xDifference * xDifference + yDifference * yDifference)
        let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))

        switch gesture.state {
        case .began:
            self.deltaAngle = angle - atan2f(Float(componentView.transform.b), Float(componentView.transform.a))
            self.initialDistance = distance
        case .changed:
            let angleDiff = Float(self.deltaAngle) - angle
            self.scale = distance / self.initialDistance
            self.scale *= self.savedScale
            
            self.viewModel?.componentDidRotate(by: CGFloat(angleDiff))
            self.viewModel?.componentDidScale(by: self.scale)

        case .ended, .possible:
            self.savedScale = self.scale
        default:
            break
        }
    }
    
    func contentViewDidPan(_ componentView: ComponentView, with gesture: UIPanGestureRecognizer) {
        guard let contentView = componentView.contentView else { return }
        switch gesture.state {
        case .began:
            let touchCGPoint = gesture.location(in: self.pageView)
            self.viewModel?.canvasDidTap(at: self.computePointToAbsolute(at: touchCGPoint))
            
        default:
            let translation = gesture.translation(in: self.view)
            var contentViewOriginFromPage = componentView.convert(contentView.layer.frame.origin, to: self.pageView)
            contentViewOriginFromPage = CGPoint(x: contentViewOriginFromPage.x + translation.x, y: contentViewOriginFromPage.y + translation.y)
            let computedOrigin = self.computePointToAbsolute(at: contentViewOriginFromPage)
            self.viewModel?.componentDidDrag(at: computedOrigin)
        }
    }
}
