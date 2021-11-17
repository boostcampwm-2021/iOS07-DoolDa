//
//  DiaryPageView.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/15.
//

import Combine
import UIKit

import SnapKit

class DiaryPageViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let cellIdentifier: String = "DiaryPageViewCell"
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var widthRatioFromAbsolute: CGFloat {
        return self.frame.size.width / 1700.0
    }
    
    private var heightRatioFromAbsolute: CGFloat {
        return self.frame.size.height / 3000.0
    }
    
    private var rawPageEntity: RawPageEntity? {
        didSet { self.drawPage() }
    }
    
    // MARK: - Subviews
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }
    
    // MARK: - Lifecycle Methods
    
    override func layoutSubviews() {
        self.drawPage()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.black.cgColor
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
    
    private func drawPage() {
        guard let rawPage = self.rawPageEntity else { return }
        self.subviews.forEach { $0.removeFromSuperview() }
        let backgroundColor = rawPage.backgroundType.rawValue
        self.backgroundColor = UIColor(cgColor: backgroundColor)
        for componentEntity in rawPage.components {
            let computedCGRect = CGRect(
                origin: self.computePointFromAbsolute(at: componentEntity.origin),
                size: self.computeSizeFromAbsolute(with: componentEntity.frame.size)
            )
            
            switch componentEntity {
            case let photoComponentEtitiy as PhotoComponentEntity:
                let photoComponentView = UIImageView(frame: computedCGRect)
                photoComponentView.kf.setImage(with: photoComponentEtitiy.imageUrl)
                self.addSubview(photoComponentView)
                let transform = CGAffineTransform.identity
                    .rotated(by: componentEntity.angle)
                    .scaledBy(x: componentEntity.scale, y: componentEntity.scale)
                photoComponentView.transform = transform
                photoComponentView.layer.shadowColor = UIColor.lightGray.cgColor
                photoComponentView.layer.shadowOpacity = 0.3
                photoComponentView.layer.shadowRadius = 10
                photoComponentView.layer.shadowOffset = CGSize(width: -5, height: -5)
            default:
                break
            }
        }
    }
    
    func displayRawPage(with rawPageEntityPublisher: AnyPublisher<RawPageEntity, Error>) {
        self.cancellables = []
        rawPageEntityPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                return
            }, receiveValue: { [weak self] rawPageEntity in
                self?.rawPageEntity = rawPageEntity
            })
            .store(in: &self.cancellables)
    }
}
