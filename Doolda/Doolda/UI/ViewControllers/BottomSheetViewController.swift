//
//  BottomSheetViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/09.
//

import UIKit

import SnapKit

class BottomSheetViewController: UIViewController {
    enum BottomSheetDetent {
        case large
        case smallLarge
        case medium
        case zero
        
        func calculateHeight(baseViwe: UIView) -> CGFloat {
            switch self {
            case .large:
                return baseViwe.frame.size.height * 0.1
            case .smallLarge:
                return baseViwe.frame.size.height * 0.3
            case .medium:
                return baseViwe.frame.size.height * 0.5
            case .zero:
                return baseViwe.frame.size.height * 1.0
            }
        }
    }
    
    // MARK: - Subviews
    
    lazy var body: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BottomSheetBackgroundColor")
        return view
    }()

    // MARK: - Public Properties
    
    var detent: BottomSheetDetent = .medium
    
    // MARK: - Private Properties
    
    private let bottomSheetPanMinMoveConstant: CGFloat = 30.0
    private let bottomSheetPanMinCloseConstant: CGFloat = 150.0

    private lazy var bottomSheetTopConstraint = self.body.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.frame.height)
    
    // MARK: - Initializers
    
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
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    // MARK: - Override Methods
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let duration = flag ? 0.25 : 0.0
        
        hideBottomSheet(duration: duration) {
            super.dismiss(animated: false, completion: completion)
        }
    }
    
    // MARK: - Helpers
    
    private func configureCommon() {
        self.modalPresentationStyle = .overFullScreen
    }
    
    private func configureUI() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(_:)))
        panGestureRecognizer.delaysTouchesBegan = false
        panGestureRecognizer.delaysTouchesEnded = false
        self.view.addGestureRecognizer(panGestureRecognizer)
        self.dimmedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmedViewDidTap(_:))))
        
        self.view.addSubview(dimmedView)
        self.dimmedView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        self.view.addSubview(body)
        self.body.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view)
        }
        
        self.bottomSheetTopConstraint.isActive = true
    }
    
    // MARK: - Private Method
    
    private func showBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.bottomSheetTopConstraint.constant = self.detent.calculateHeight(baseViwe: self.view)
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    private func hideBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.bottomSheetTopConstraint.constant = self.view.frame.height
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    @objc private func dimmedViewDidTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func viewDidPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let bottomSheetHeight = self.detent.calculateHeight(baseViwe: self.view)
        
        switch sender.state {
        case .began: break
        case .changed:
            if translation.y > 0 && bottomSheetHeight + translation.y > bottomSheetPanMinMoveConstant {
                self.bottomSheetTopConstraint.constant = bottomSheetHeight + translation.y
            }
        case .ended:
            if translation.y > bottomSheetPanMinCloseConstant {
                self.dismiss(animated: true, completion: nil)
            } else {
                fallthrough
            }
        default:
            showBottomSheet()
        }
    }
}
