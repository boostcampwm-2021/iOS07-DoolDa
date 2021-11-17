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
    
    // MARK: - Subviews
    
    private lazy var pageView: UIView = UIView()
    private lazy var layeredView: UIView = UIView()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.text = "25"
        label.font = .systemFont(ofSize: 35)
        return label
    }()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.text = "Oct"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var dayLabelUnderBar: UIView = {
        let view = UIView()
        view.backgroundColor = .label
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        return activityIndicator
    }()
    
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
    
    private var timestamp: Date? {
        didSet { }
    }
    
    // MARK: - Initializers
    
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
        
        self.addSubview(self.pageView)
        self.pageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.layeredView)
        self.layeredView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.layeredView.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.layeredView.addSubview(self.dayLabel)
        self.dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        self.layeredView.addSubview(self.dayLabelUnderBar)
        self.dayLabelUnderBar.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(self.dayLabel.snp.width)
            make.top.equalTo(self.dayLabel.snp.bottom)
            make.centerX.equalTo(self.dayLabel.snp.centerX)
        }
        
        self.layeredView.addSubview(self.monthLabel)
        self.monthLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.dayLabel.snp.bottom)
            make.leading.equalTo(self.dayLabel.snp.trailing).offset(4)
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
    
    private func drawPage() {
        guard let rawPage = self.rawPageEntity else { return }
        self.pageView.subviews.forEach { $0.removeFromSuperview() }
        
        self.backgroundColor = UIColor(cgColor: rawPage.backgroundType.rawValue)
        for componentEntity in rawPage.components {
            let computedCGRect = CGRect(
                origin: self.computePointFromAbsolute(at: componentEntity.origin),
                size: self.computeSizeFromAbsolute(with: componentEntity.frame.size)
            )
            
            switch componentEntity {
            case let photoComponentEtitiy as PhotoComponentEntity:
                let photoComponentView = UIImageView(frame: computedCGRect)
                photoComponentView.kf.setImage(with: photoComponentEtitiy.imageUrl)
                self.pageView.addSubview(photoComponentView)
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
        self.activityIndicator.stopAnimating()
    }
    
    func displayRawPage(with rawPageEntityPublisher: AnyPublisher<RawPageEntity, Error>) {
        self.activityIndicator.startAnimating()
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
