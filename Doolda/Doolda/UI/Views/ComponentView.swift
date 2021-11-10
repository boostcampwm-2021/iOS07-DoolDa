//
//  ComponentView.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

protocol ComponentViewDelegate: AnyObject {
    func leftTopControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer)
    func leftBottomControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer)
    func rightTopControlDidTap(_ componentView: ComponentView, with gesture: UITapGestureRecognizer)
    func rightBottomcontrolDidPan(_ componentView: ComponentView, with gesture: UIPanGestureRecognizer)
    func contentViewDidPan(_ componentView: ComponentView, with gesture: UIPanGestureRecognizer)
}

class ComponentView: UIView {
    
    // MARK: - Subviews
    
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
    
    // MARK: - Public Properties
    
    var controls: [UIControl] = []
    var isSelected: Bool = false {
        didSet { self.changeView(as: self.isSelected) }
    }
    
    // MARK: - Private Properties
    
    private(set) var contentView: UIView?
    private weak var delegate: ComponentViewDelegate?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    
    convenience init(component: UIView, delegate: ComponentViewDelegate) {
        self.init(frame: CGRect(
            x: component.frame.minX-15,
            y: component.frame.minY-15,
            width: component.frame.width+30,
            height: component.frame.height+30))
        self.contentView = component
        self.delegate = delegate
        self.configureUI()
        self.bindUI()
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
        guard let contentView = contentView else { return }
        contentView.isUserInteractionEnabled = true
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
        
        self.addSubview(self.leftTopControl)
        self.controls.append(self.leftTopControl)
        self.leftTopControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalTo(contentView.snp.leading)
            make.centerY.equalTo(contentView.snp.top)
        }
        
        let controlForwardImageView = UIImageView(image: .controlForward)
        self.leftTopControl.addSubview(controlForwardImageView)
        controlForwardImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.leftBottomControl)
        self.controls.append(self.leftBottomControl)
        self.leftBottomControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalTo(contentView.snp.leading)
            make.centerY.equalTo(contentView.snp.bottom)
        }
        
        let controlBackwardImageView = UIImageView(image: .controlBackward)
        self.leftBottomControl.addSubview(controlBackwardImageView)
        controlBackwardImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.rightTopControl)
        self.controls.append(self.rightTopControl)
        self.rightTopControl.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalTo(contentView.snp.trailing)
            make.centerY.equalTo(contentView.snp.top)
        }
        
        let controlDeleteImageView = UIImageView(image: .controlDelete)
        self.rightTopControl.addSubview(controlDeleteImageView)
        controlDeleteImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.addSubview(self.rightBottomcontrol)
        self.controls.append(self.rightBottomcontrol)
        self.rightBottomcontrol.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerX.equalTo(contentView.snp.trailing)
            make.centerY.equalTo(contentView.snp.bottom)
        }
        
        let controlTransferImageView = UIImageView(image: .controlTransfer)
        self.rightBottomcontrol.addSubview(controlTransferImageView)
        controlTransferImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindUI() {
        self.contentView?.publisher(for: UIPanGestureRecognizer())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gesture in
                guard let self = self,
                      let panGesture = gesture as? UIPanGestureRecognizer else { return }
                self.delegate?.contentViewDidPan(self, with: panGesture)
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
            self.contentView?.layer.borderWidth = 1
            self.contentView?.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            self.contentView?.layer.borderWidth = 0
        }
        self.leftTopControl.isHidden = !selectedState
        self.leftBottomControl.isHidden = !selectedState
        self.rightTopControl.isHidden = !selectedState
        self.rightBottomcontrol.isHidden = !selectedState
    }
}
