//
//  DiaryPageView.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/29.
//

import Combine
import UIKit

protocol DiaryPageViewDelegate: AnyObject {
    func diaryPageDrawDidFinish(_ diaryPageView: DiaryPageView)
}

class DiaryPageView: UIView {
    
    // MARK: - Subviews
    
    private lazy var componentCanvasView: UIView = UIView()
    
    // MARK: - Public Properties
    
    weak var delegate: DiaryPageViewDelegate?
    @Published var pageBackgroundColor: UIColor?
    @Published var components: [ComponentEntity]?
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var widthRatioFromAbsolute: CGFloat { self.frame.size.width / 1700.0 }
    private var heightRatioFromAbsolute: CGFloat {  self.frame.size.height / 3000.0 }
    
    // MARK: - Initializers
    
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
    
    // MARK: - Override Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawComponents(using: self.components, with: self.pageBackgroundColor)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.addSubview(self.componentCanvasView)
        self.componentCanvasView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindUI() {
        Publishers.CombineLatest(self.$components, self.$pageBackgroundColor)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] components, pageBackgroundColor in
                self?.drawComponents(using: components, with: pageBackgroundColor)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods
    
    private func drawComponents(using components: [ComponentEntity]?, with color: UIColor?) {
        guard let components = components else { return }
        self.backgroundColor = pageBackgroundColor
        self.componentCanvasView.subviews.forEach { $0.removeFromSuperview() }
        
        for component in components {
            guard let componentView = self.getComponentView(from: component) else { return }
            componentView.frame = CGRect(
                origin: self.computePointFromAbsolute(at: component.origin),
                size: self.computeSizeFromAbsolute(with: component.frame.size)
            )
            componentView.transform = CGAffineTransform.identity
                .rotated(by: component.angle)
                .scaledBy(x: component.scale, y: component.scale)
            
            self.componentCanvasView.addSubview(componentView)
        }
        self.delegate?.diaryPageDrawDidFinish(self)
    }

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
