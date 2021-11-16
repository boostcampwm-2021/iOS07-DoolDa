//
//  BottomSheetViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

class BottomSheetViewController: UIViewController {
    enum BottomSheetDetent {
        case large
        case smallLarge
        case medium
        case zero
        
        func calculateHeight(baseView: UIView) -> CGFloat {
            switch self {
            case .large:
                return baseView.frame.size.height * 0.9
            case .smallLarge:
                return baseView.frame.size.height * 0.7
            case .medium:
                return baseView.frame.size.height * 0.5
            case .zero:
                return .zero
            }
        }
    }
    
    // MARK: - Subviews
    
    lazy var body: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: -10)
        return view
    }()
    
    private lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .dooldaBottomSheetBackgroundColor
        return view
    }()

    // MARK: - Public Properties
    
    @Published var detent: BottomSheetDetent = .zero
    
    // MARK: - Private Properties
    
    private let bottomSheetMinHeight: CGFloat = 150.0
    private let bottomSheetPanMinMoveConstant: CGFloat = 30.0
    private let bottomSheetPanMinCloseConstant: CGFloat = 150.0

    private var cancellables = Set<AnyCancellable>()
    
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
        bindUI()
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
        self.view.addSubview(dimmedView)
        self.dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(body)
        self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        self.body.frame.size = CGSize(width: self.view.frame.width, height: self.detent.calculateHeight(baseView: self.view))
    }
    
    private func bindUI() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.delaysTouchesBegan = false
        panGestureRecognizer.delaysTouchesEnded = false
        
        self.view.publisher(for: panGestureRecognizer)
            .compactMap { $0 as? UIPanGestureRecognizer }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sender in
                self?.viewDidPan(sender)
            }
            .store(in: &self.cancellables)
        
        self.dimmedView.publisher(for: UITapGestureRecognizer())
            .compactMap { $0 as? UITapGestureRecognizer }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sender in
                self?.dimmedViewDidTap(sender)
            }
            .store(in: &self.cancellables)
        
        self.$detent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detent in
                guard let self = self else { return }
                self.body.frame.size = CGSize(width: self.view.frame.width, height: self.detent.calculateHeight(baseView: self.view))
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Method
    
    private func showBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height - self.detent.calculateHeight(baseView: self.view))
        } completion: { _ in
            completion?()
        }
    }
    
    private func hideBottomSheet(duration: CGFloat = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration) {
            self.body.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        } completion: { _ in
            completion?()
        }
    }
    
    private func dimmedViewDidTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func viewDidPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let dimmedViewHeight = self.view.frame.height - self.detent.calculateHeight(baseView: self.view)
        
        switch sender.state {
        case .began: break
        case .changed:
            if translation.y > 0 &&
               self.body.frame.height > self.bottomSheetMinHeight &&
                dimmedViewHeight + translation.y > self.bottomSheetPanMinMoveConstant {
                self.body.frame.origin = CGPoint(x: self.body.frame.origin.x, y: dimmedViewHeight + translation.y)
            }
        case .ended, .possible:
            if translation.y > self.bottomSheetPanMinCloseConstant {
                self.dismiss(animated: true, completion: nil)
            } else {
                fallthrough
            }
        default:
            showBottomSheet()
        }
    }
}
