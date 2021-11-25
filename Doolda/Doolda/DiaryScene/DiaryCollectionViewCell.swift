//
//  DiaryCollectionViewCell.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/15.
//

import Combine
import UIKit

import Kingfisher
import SnapKit

class DiaryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let identifier: String = "DiaryCollectionViewCell"
    
    // MARK: - Subviews
    
    private lazy var pageView: UIView = UIView()
    private lazy var layeredView: UIView = UIView()
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    private lazy var dayLabelUnderBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var darkModeDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        view.alpha = 0.1
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    // MARK: - Public Properties
    
    var timestamp: Date? {
        didSet {
            guard let timestamp = timestamp else { return }
            self.dayLabel.text = DateFormatter.dayFormatter.string(from: timestamp)
            self.monthLabel.text = DateFormatter.monthNameFormatter.string(from: timestamp).uppercased()
        }
    }
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var rawPageEntityPublisherCancellable: Cancellable?
    private var widthRatioFromAbsolute: CGFloat {
        return self.frame.size.width / 1700.0
    }
    
    private var heightRatioFromAbsolute: CGFloat {
        return self.frame.size.height / 3000.0
    }
    
    private(set) var rawPageEntity: RawPageEntity? {
        didSet { self.drawPage() }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.configureFont()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
        self.configureFont()
        self.bindUI()
    }
    
    // MARK: - Lifecycle Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawPage()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.clipsToBounds = true
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
            make.width.equalTo(self.snp.width).dividedBy(7.0)
            make.height.equalTo(self.dayLabel.snp.width)
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
            make.centerY.equalTo(self.dayLabel.snp.centerY)
            make.leading.equalTo(self.dayLabel.snp.trailing).offset(5)
            make.width.equalTo(self.snp.width).dividedBy(7.0)
            make.height.equalTo(self.monthLabel.snp.width)
        }
    }
    
    private func bindUI() {
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    self.darkModeDimView.isHidden = false
                } else {
                    self.darkModeDimView.isHidden = true
                }
            }
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
        
        self.pageView.addSubview(self.darkModeDimView)
        self.darkModeDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
            case let stickerComponentEntity as StickerComponentEntity:
                let stickerComponentView = UIImageView(frame: computedCGRect)
                stickerComponentView.image = UIImage(named: stickerComponentEntity.name)
                stickerComponentView.contentMode = .scaleAspectFit
                self.pageView.addSubview(stickerComponentView)
                let transform = CGAffineTransform.identity
                    .rotated(by: componentEntity.angle)
                    .scaledBy(x: componentEntity.scale, y: componentEntity.scale)
                stickerComponentView.transform = transform
            case let textComponentEntity as TextComponentEntity:
                let textComponentView = UILabel(frame: computedCGRect)
                textComponentView.numberOfLines = 0
                textComponentView.textAlignment = .center
                textComponentView.adjustsFontSizeToFitWidth = true
                textComponentView.adjustsFontForContentSizeCategory = true
                textComponentView.text = textComponentEntity.text
                textComponentView.textColor = UIColor(cgColor: textComponentEntity.fontColor.rawValue)
                textComponentView.font = .systemFont(ofSize: textComponentEntity.fontSize)
                
                self.pageView.addSubview(textComponentView)
                
                let transform = CGAffineTransform.identity
                    .rotated(by: componentEntity.angle)
                    .scaledBy(x: componentEntity.scale, y: componentEntity.scale)
                textComponentView.transform = transform
            default:
                break
            }
        }
        self.activityIndicator.stopAnimating()
        self.monthLabel.sizeToFit()
    }
    
    private func configureFont() {
        self.dayLabel.font = .systemFont(ofSize: 100)
        self.monthLabel.font = .systemFont(ofSize: 100)
    }
    
    func displayRawPage(with rawPageEntityPublisher: AnyPublisher<RawPageEntity, Error>) {
        self.activityIndicator.startAnimating()
        self.rawPageEntityPublisherCancellable?.cancel()
        self.rawPageEntityPublisherCancellable = rawPageEntityPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                return
            }, receiveValue: { [weak self] rawPageEntity in
                self?.rawPageEntity = rawPageEntity
            })
    }

}
