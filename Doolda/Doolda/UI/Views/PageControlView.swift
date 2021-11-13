//
//  ComponentView.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

protocol ControlViewDelegate: AnyObject {
    func controlViewDidPan(_ componentView: PageControlView, with gesture: UIPanGestureRecognizer)
    func leftTopControlDidTap(_ componentView: PageControlView, with gesture: UITapGestureRecognizer)
    func leftBottomControlDidTap(_ componentView: PageControlView, with gesture: UITapGestureRecognizer)
    func rightTopControlDidTap(_ componentView: PageControlView, with gesture: UITapGestureRecognizer)
    func rightBottomcontrolDidPan(_ componentView: PageControlView, with gesture: UIPanGestureRecognizer)
}

class PageControlView: UIView {
    
    // MARK: - Subviews
    lazy var controlsView: UIView = {
        return UIView()
    }()
    
    private lazy var leftTopControl: UIControl = {
        return self.makeControl()
    }()
    
    private lazy var leftBottomControl: UIControl = {
        return self.makeControl()
    }()
    
    private lazy var rightTopControl: UIControl = {
        return self.makeControl()
    }()
    
    private lazy var rightBottomcontrol: UIControl = {
        return self.makeControl()
    }()
    
    lazy var componentSpaceView: UIView = {
        return UIView()
    }()
    
    // MARK: - Public Properties
    
    var controls: [UIControl] = []
    var isSelected: Bool = false {
        didSet { self.changeView(as: self.isSelected) }
    }
    
    // MARK: - Private Properties
    
    private weak var delegate: ControlViewDelegate?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    
    convenience init(frame: CGRect, delegate: ControlViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.addSubview(componentSpaceView)
        
        self.controlsView.isUserInteractionEnabled = true
        self.addSubview(self.controlsView)
        self.controlsView.snp.makeConstraints { make in
            make.edges.equalTo(componentSpaceView).inset(-15)
        }
        
        self.controlsView.addSubview(self.leftTopControl)
        self.controls.append(self.leftTopControl)
        self.leftTopControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let controlForwardImageView = UIImageView(image: .controlForward)
        self.leftTopControl.addSubview(controlForwardImageView)
        controlForwardImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.controlsView.addSubview(self.leftBottomControl)
        self.controls.append(self.leftBottomControl)
        self.leftBottomControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let controlBackwardImageView = UIImageView(image: .controlBackward)
        self.leftBottomControl.addSubview(controlBackwardImageView)
        controlBackwardImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.controlsView.addSubview(self.rightTopControl)
        self.controls.append(self.rightTopControl)
        self.rightTopControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let controlDeleteImageView = UIImageView(image: .controlDelete)
        self.rightTopControl.addSubview(controlDeleteImageView)
        controlDeleteImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.controlsView.addSubview(self.rightBottomcontrol)
        self.controls.append(self.rightBottomcontrol)
        self.rightBottomcontrol.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()

        }
        
        let controlTransferImageView = UIImageView(image: .controlTransfer)
        self.rightBottomcontrol.addSubview(controlTransferImageView)
        controlTransferImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindUI() {
        self.controlsView.publisher(for: UIPanGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let panGesture = gesture as? UIPanGestureRecognizer else { return }
                self.delegate?.controlViewDidPan(self, with: panGesture)
            }
            .store(in: &cancellables)
        
        self.leftTopControl.publisher(for: UITapGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let tapGesture = gesture as? UITapGestureRecognizer else { return }
                self.delegate?.leftTopControlDidTap(self, with: tapGesture)
            }
            .store(in: &cancellables)
        
        self.leftBottomControl.publisher(for: UITapGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let tapGesture = gesture as? UITapGestureRecognizer else { return }
                self.delegate?.leftBottomControlDidTap(self, with: tapGesture)
            }
            .store(in: &cancellables)
        
        self.rightTopControl.publisher(for: UITapGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let tapGesture = gesture as? UITapGestureRecognizer else { return }
                self.delegate?.rightTopControlDidTap(self, with: tapGesture)
            }
            .store(in: &cancellables)
        
        self.rightBottomcontrol.publisher(for: UIPanGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let panGesture = gesture as? UIPanGestureRecognizer else { return }
                self.delegate?.rightBottomcontrolDidPan(self, with: panGesture)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func makeControl() -> UIControl {
        let control = UIControl()
        control.isHidden = true
        control.backgroundColor = .lightGray
        control.layer.cornerRadius = 15
        return control
    }
    
    private func changeView(as selectedState: Bool) {
        if selectedState {
            self.componentSpaceView.layer.borderWidth = 1
            self.componentSpaceView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            self.componentSpaceView.layer.borderWidth = 0
        }
        self.leftTopControl.isHidden = !selectedState
        self.leftBottomControl.isHidden = !selectedState
        self.rightTopControl.isHidden = !selectedState
        self.rightBottomcontrol.isHidden = !selectedState
    }
}
