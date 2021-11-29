//
//  EditPageViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit
import Kingfisher

class EditPageViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
    private lazy var cancelButton: UIButton = {
        var button = UIButton()
        button.setImage(.xmark, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        var button = UIButton()
        button.setImage(.checkmark, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
        return button
    }()
    
    private lazy var pageView: UIView = {
        var view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
        
    private lazy var pageControlView: PageComponentControlView = {
        var controlView = PageComponentControlView(frame: .zero, delegate: self)
        return controlView
    }()
    
    private lazy var addPhotoComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.photo, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
        return button
    }()
    
    private lazy var addTextComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.textformat, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
        return button
    }()
    
    private lazy var addStickerComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.sticker, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
        return button
    }()
    
    private lazy var changeBackgroundTypeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.background, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: 21), forImageIn: .normal)
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
    
    private lazy var activityIndicator: CustomActivityIndicator = {
        let customActivityIndicator = CustomActivityIndicator(subTitle: "페이지 저장중이에요!!🦔🦔", loadingImage: .hedgehogWriting)
        customActivityIndicator.isHidden = true
        return customActivityIndicator
    }()
    
    private lazy var hapticGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .light)
        return generator
    }()
    
    // MARK: - Override Properties
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: EditPageViewModelProtocol?
    private var componentViewDictionary: [ComponentEntity: UIView] = [:]
    
    var widthRatioFromAbsolute: CGFloat {
        return self.pageView.frame.size.width / 1700.0
    }
    
    var heightRatioFromAbsolute: CGFloat {
        return self.pageView.frame.size.height / 3000.0
    }
    
    private var selectedComponentInitialRect: CGRect = .zero
    private var selectedComponentInitialScale: CGFloat = 0

    private var initialOrigin: CGPoint = .zero
    
    private var scale: CGFloat = 0
    private var savedScale: CGFloat = 1
    private var savedDistance: CGFloat = 0
    private var deltaAngle: Float = 0
    
    // MARK: - Initializers
    
    convenience init(viewModel: EditPageViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.editPageViewDidAppear()
    }
    
    // MARK: - Helpers
        
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "페이지 편집"
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
        self.pageView.layer.cornerRadius = 4
        self.pageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.scrollView.snp.top).offset(12)
            make.width.equalTo(self.pageView.snp.height).multipliedBy(17.0 / 30.0)
            let screenHeight = UIScreen.main.bounds.size.height
            if screenHeight > 750 {
                make.height.equalTo(self.scrollView.snp.height).offset(-100)
            } else {
                make.height.equalTo(self.scrollView.snp.height).offset(-45)
            }
        }
        
        self.contentView.addSubview(self.pageControlView)
        self.pageControlView.clipsToBounds = true
        self.pageControlView.isUserInteractionEnabled = true
        self.pageControlView.snp.makeConstraints { make in
            make.edges.equalTo(self.pageView)
        }
        
        self.contentView.addSubview(self.componentsStackView)
        self.componentsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.pageView)
            make.top.equalTo(self.pageView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(150)
        }
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureFont() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }
    
    private func bindUI() {
        self.cancelButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                let alert = UIAlertController.selectAlert(
                    title: "편집 나가기",
                    message: "페이지를 저장하지 않고 나갈 시, 작성한 내용은 저장되지 않습니다.",
                    leftActionTitle: "취소",
                    rightActionTitle: "나가기",
                    action: { [weak self] _ in
                        self?.viewModel?.cancelEditingPageButtonDidTap()
                    })
                self.present(alert, animated: true)
            }.store(in: &self.cancellables)
        
        self.saveButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                let alert = UIAlertController.selectAlert(
                    title: "편집 저장하기",
                    message: "페이지를 저장하시겠습니까?, 저장 후 더 이상 편집할 수 없습니다.",
                    leftActionTitle: "취소",
                    rightActionTitle: "저장",
                    action: { [weak self] _ in
                        self?.activityIndicator.startAnimating()
                        self?.viewModel?.saveEditingPageButtonDidTap()
                    })
                self.present(alert, animated: true)
            }.store(in: &self.cancellables)
        
        self.pageControlView.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] gesture in
                guard let self = self else { return }
                let touchCGPoint = gesture.location(in: self.pageView)
                self.viewModel?.canvasDidTap(at: self.computePointToAbsolute(at: touchCGPoint))
            }.store(in: &self.cancellables)
        
        self.pageControlView.publisher(for: UIPanGestureRecognizer())
            .sink { [weak self] gesture in
                guard let self = self,
                    let panGestrue = gesture as? UIPanGestureRecognizer else { return }
                switch gesture.state {
                case .began:
                    let touchCGPoint = panGestrue.location(in: self.pageControlView)
                    self.viewModel?.canvasDidTap(at: self.computePointToAbsolute(at: touchCGPoint))
                    self.initialOrigin = self.pageControlView.componentSpaceView.frame.origin
                    fallthrough
                case .changed:
                    let translation = panGestrue.translation(in: self.pageControlView)
                    let contentViewOriginFromPage = CGPoint(
                        x: self.initialOrigin.x + translation.x,
                        y: self.initialOrigin.y + translation.y
                    )
                    let computedOrigin = self.computePointToAbsolute(at: contentViewOriginFromPage)
                    self.viewModel?.componentDidDrag(at: computedOrigin)
                default:
                    break
                }
                
            }.store(in: &self.cancellables)
        
        self.addPhotoComponentButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                self.viewModel?.photoComponentAddButtonDidTap()
            }.store(in: &self.cancellables)
        
        self.addTextComponentButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                self.viewModel?.textComponentAddButtonDidTap()
            }.store(in: &self.cancellables)
        
        self.addStickerComponentButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                self.viewModel?.stickerComponentAddButtonDidTap()
            }.store(in: &self.cancellables)
        
        self.changeBackgroundTypeButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.hapticGenerator.prepare()
                self.hapticGenerator.impactOccurred()
                self.viewModel?.backgroundTypeButtonDidTap()
            }.store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    private func bindViewModel() {
        self.viewModel?.selectedComponentPublisher
            .sink { [weak self] componentEntity in
                guard let self = self else { return }
                self.pageControlView.isSelected = false
                guard let componentEntity = componentEntity,
                      let componentView = self.componentViewDictionary[componentEntity] else { return }
                self.pageControlView.isSelected = true
                
                componentView.transform = CGAffineTransform.identity
                self.pageControlView.componentSpaceView.transform = CGAffineTransform.identity

                let computedCGRect = CGRect(
                    origin: self.computePointFromAbsolute(at: componentEntity.origin),
                    size: self.computeSizeFromAbsolute(with: componentEntity.frame.size)
                )
                
                self.selectedComponentInitialRect = computedCGRect
                self.selectedComponentInitialScale = componentEntity.scale
                
                componentView.layer.frame = computedCGRect
                self.pageControlView.componentSpaceView.frame = computedCGRect
                
                let transform = CGAffineTransform.identity.rotated(
                    by: componentEntity.angle
                ).scaledBy(
                    x: componentEntity.scale,
                    y: componentEntity.scale
                )
                componentView.transform = transform
                
                if let textComponentEntity = componentEntity as? TextComponentEntity,
                   let textComponentView = componentView as? UILabel {
                    textComponentView.text = textComponentEntity.text
                    textComponentView.textColor = UIColor(cgColor: textComponentEntity.fontColor.rawValue)
                    textComponentView.font = .systemFont(ofSize: textComponentEntity.fontSize)
                }
                
                self.pageControlView.componentSpaceView.transform = transform
                self.pageControlView.controlsView.transform = transform
                
                self.pageControlView.componentSpaceView.layer.borderWidth = 1/componentEntity.scale
                self.pageControlView.controls.forEach { control in
                    control.transform = CGAffineTransform.identity.scaledBy(x: 1/componentEntity.scale, y: 1/componentEntity.scale)
                }
            }.store(in: &self.cancellables)
        
        self.viewModel?.componentsPublisher
            .sink { [weak self] componenets in
                guard let self = self else { return }
                self.componentViewDictionary.forEach { key, value in
                    value.removeFromSuperview()
                    self.componentViewDictionary[key] = nil
                }
                for componentEntity in componenets {
                    guard let componentView = self.getComponentView(from: componentEntity) else { return }
                    componentView.frame = CGRect(
                        origin: self.computePointFromAbsolute(at: componentEntity.origin),
                        size: self.computeSizeFromAbsolute(with: componentEntity.frame.size)
                    )
                    componentView.transform = CGAffineTransform.identity
                        .rotated(by: componentEntity.angle)
                        .scaledBy(x: componentEntity.scale, y: componentEntity.scale)
                    self.pageView.addSubview(componentView)
                    self.componentViewDictionary[componentEntity] = componentView
                }
            }.store(in: &self.cancellables)
        
        self.viewModel?.backgroundPublisher
            .sink { backgroundType in
                self.pageView.backgroundColor = UIColor(cgColor: backgroundType.rawValue)
            }.store(in: &self.cancellables)
        
        self.viewModel?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error as? LocalizedError else { return }
                let alert = UIAlertController.defaultAlert(title: "알림", message: error.localizedDescription, handler: { _ in
                    self?.activityIndicator.stopAnimating()
                })
                self?.present(alert, animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods

    private func getComponentView(from componentEntity: ComponentEntity) -> UIView? {
        switch componentEntity {
        case let photoComponentEtitiy as PhotoComponentEntity:
            let photoView =  UIImageView()
            photoView.kf.setImage(with: photoComponentEtitiy.imageUrl)
            photoView.layer.shadowColor = UIColor.lightGray.cgColor
            photoView.layer.shadowOpacity = 0.3
            photoView.layer.shadowRadius = 10
            photoView.layer.shadowOffset = CGSize(width: -5, height: -5)
            return photoView
        case let stickerComponentEntity as StickerComponentEntity:
            let stickerView = UIImageView()
            stickerView.image = UIImage(named: stickerComponentEntity.name)
            stickerView.contentMode = .scaleAspectFit
            return stickerView
        case let textComponentEntity as TextComponentEntity:
            let textView = UILabel()
            textView.numberOfLines = 0
            textView.textAlignment = .center
            textView.adjustsFontSizeToFitWidth = true
            textView.adjustsFontForContentSizeCategory = true
            textView.text = textComponentEntity.text
            textView.textColor = UIColor(cgColor: textComponentEntity.fontColor.rawValue)
            textView.font = .systemFont(ofSize: textComponentEntity.fontSize)
            return textView
        default: return nil
        }
    }
    
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
        let computedWidth =  size.width * self.widthRatioFromAbsolute
        let computedHeight = size.height * self.heightRatioFromAbsolute
        return CGSize(width: computedWidth, height: computedHeight)
    }
}

extension EditPageViewController: PageComponentControlViewDelegate {
    func controlViewDidTap(_ pageComponentControlView: PageComponentControlView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentDidTap()
    }
    
    func leftTopControlDidTap(_ pageControlView: PageComponentControlView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentBringFrontControlDidTap()
    }
    
    func leftBottomControlDidTap(_ pageControlView: PageComponentControlView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentSendBackControlDidTap()
    }
    
    func rightTopControlDidTap(_ pageControlView: PageComponentControlView, with gesture: UITapGestureRecognizer) {
        self.viewModel?.componentRemoveControlDidTap()
    }
    
    func rightBottomcontrolDidPan(_ pageControlView: PageComponentControlView, with gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: self.view)
        let center = CGPoint(x: self.selectedComponentInitialRect.midX, y: self.selectedComponentInitialRect.midY)
        let xDifference = (center.x - touchLocation.x)
        let yDifference = (center.y - touchLocation.y)
        let distance = sqrt(xDifference * xDifference + yDifference * yDifference)
        let angle = atan2f(Float(touchLocation.y - center.y), Float(touchLocation.x - center.x))

        switch gesture.state {
        case .began:
            self.deltaAngle = angle - atan2f(
                Float(pageControlView.componentSpaceView.transform.b),
                Float(pageControlView.componentSpaceView.transform.a)
            )
            self.savedDistance = distance
            self.savedScale = self.selectedComponentInitialScale
        case .changed:
            scale = distance / self.savedDistance
            scale *= savedScale
            
            let radian = CGFloat(-(Float(self.deltaAngle) - angle))
            self.viewModel?.componentDidRotate(by: radian)
            self.viewModel?.componentDidScale(by: scale)
        case .ended, .possible:
            savedScale = scale
        default:
            break
        }
    }
    
    func controlViewDidPan(_ pageControlView: PageComponentControlView, with gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let touchCGPoint = gesture.location(in: self.pageControlView)
            self.viewModel?.canvasDidTap(at: self.computePointToAbsolute(at: touchCGPoint))
            self.initialOrigin = self.selectedComponentInitialRect.origin
            fallthrough
        case .changed:
            let translation = gesture.translation(in: self.pageView)
            let contentViewOriginFromPage = CGPoint(
                x: self.initialOrigin.x + translation.x,
                y: self.initialOrigin.y + translation.y
            )
            let computedOrigin = self.computePointToAbsolute(at: contentViewOriginFromPage)
            self.viewModel?.componentDidDrag(at: computedOrigin)
        default:
            break
        }
    }
}

extension EditPageViewController: PhotoPickerBottomSheetViewControllerDelegate {
    func composedPhotoDidMake(_ photoComponentEntity: PhotoComponentEntity) {
        self.hapticGenerator.prepare()
        self.hapticGenerator.impactOccurred()
        self.viewModel?.componentEntityDidAdd(photoComponentEntity)
    }
}

extension EditPageViewController: BackgroundTypePickerViewControllerDelegate {
    func backgroundTypeDidSelect(_ backgroundType: BackgroundType) {
        self.hapticGenerator.prepare()
        self.hapticGenerator.impactOccurred()
        self.viewModel?.backgroundColorDidChange(backgroundType)
    }
}

extension EditPageViewController: StickerPickerBottomSheetViewControllerDelegate {
    func stickerDidSelected(_ stickerComponentEntity: StickerComponentEntity) {
        self.hapticGenerator.prepare()
        self.hapticGenerator.impactOccurred()
        self.viewModel?.componentEntityDidAdd(stickerComponentEntity)
    }
}

extension EditPageViewController: TextEditViewControllerDelegate {
    func textInputDidEndAdd(_ textComponentEntity: TextComponentEntity) {
        self.hapticGenerator.prepare()
        self.hapticGenerator.impactOccurred()
        self.viewModel?.componentEntityDidAdd(textComponentEntity)
    }
    
    func textInputDidEndEditing(_ textComponentEntity: TextComponentEntity) {
        self.viewModel?.textComponentDidChange(to: textComponentEntity)
    }
}
