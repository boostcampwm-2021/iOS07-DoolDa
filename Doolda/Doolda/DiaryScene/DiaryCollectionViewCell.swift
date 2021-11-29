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
        self.backgroundColor = UIColor(cgColor: rawPage.backgroundType.rawValue)
        self.pageView.subviews.forEach { $0.removeFromSuperview() }
        
        for componentEntity in rawPage.components {
            guard let componentView = self.getComponentView(from: componentEntity) else { return }
            componentView.frame = CGRect(
                origin: self.computePointFromAbsolute(at: componentEntity.origin),
                size: self.computeSizeFromAbsolute(with: componentEntity.frame.size)
            )
            componentView.transform = CGAffineTransform.identity
                .rotated(by: componentEntity.angle)
                .scaledBy(x: componentEntity.scale, y: componentEntity.scale)
            
            self.pageView.addSubview(componentView)
        }

        self.activityIndicator.stopAnimating()
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
}
