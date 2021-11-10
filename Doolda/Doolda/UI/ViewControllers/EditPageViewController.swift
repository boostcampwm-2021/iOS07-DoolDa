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
    
    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        var barButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonDidTap)
        )
        return barButtonItem
    }()
    
    private lazy var saveBarButtonItem: UIBarButtonItem = {
        var barButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .plain,
            target: self,
            action: #selector(saveButtonDidTap)
        )
        return barButtonItem
    }()
    
    private lazy var pageView: UIView = {
        var view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var addPhotoComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        return button
    }()
    
    private lazy var addTextComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "textformat"), for: .normal)
        return button
    }()
    
    private lazy var addStickerComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        return button
    }()
    
    private lazy var changeBackgroundTypeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "doc"), for: .normal)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // FIXME : delete tempView
        let imageView = UIImageView(frame: CGRect(
            x: 50,
            y: 50,
            width: 200,
            height: 150))
        imageView.image = UIImage(systemName: "heart.fill")
        let tempView = ComponentView(component: imageView, delegate: self)
        self.pageView.addSubview(tempView)
        tempView.isSelected = true
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:
                                                                            UIFont(name: "Dovemayo", size: 17) as Any]
        self.title = "새 페이지"
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem

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
    
    // FIXME : should bind to viewModel
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
    }
    
    // MARK: - Private Methods
    
    @objc private func cancelButtonDidTap() {
        let alert = UIAlertController.cancelEditPageAlert { _ in
            self.viewModel?.cancelEditingPageButtonDidTap()
        }
        self.present(alert, animated: true)
    }
    
    @objc private func saveButtonDidTap() {
        let alert = UIAlertController.saveEditPageAlert { _ in
            self.viewModel?.saveEditingPageButtonDidTap()
        }
        self.present(alert, animated: true)
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
        guard let contentView = componentView.contentView else { return }
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
            scale = distance / self.initialDistance
            scale *= savedScale
            
            // viewModel.changeSelectedSclae(scale)
            // viewModel.changeSelectedRotation(angle) -> usecase에서 실제 컴포넌트에 적용 -> 타고타고내려와서 bind걸린곳에서 실제처리
            
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: CGFloat(-angleDiff))
            transform = transform.scaledBy(x: scale, y: scale)
            componentView.transform = transform
            
            let controlTransform = CGAffineTransform.identity.scaledBy(x: 1/scale, y: 1/scale)
            componentView.controls.forEach { $0.transform  = controlTransform }

            contentView.layer.borderWidth = 1 / scale
        case .ended:
            fallthrough
        case .possible:
            savedScale = scale
        default:
            break
        }
    }
    
    func contentViewDidPan(_ componentView: ComponentView, with gesture: UIPanGestureRecognizer) {
        self.viewModel?.componentDidDrag(difference: CGPoint(x: 0, y: 0))
        let translation = gesture.translation(in: self.view)
        componentView.center = CGPoint(x: componentView.center.x + translation.x, y: componentView.center.y + translation.y)
        gesture.setTranslation(.zero, in: componentView)
    }
}
