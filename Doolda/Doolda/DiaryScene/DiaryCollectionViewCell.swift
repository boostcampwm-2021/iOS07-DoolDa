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
    
    private lazy var diaryPageView: DiaryPageView = {
        let view = DiaryPageView()
        view.delegate = self
        return view
    }()
    
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
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor.black.cgColor
        
        self.addSubview(self.diaryPageView)
        self.diaryPageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.dayLabel)
        self.dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(self.snp.width).dividedBy(7.0)
            make.height.equalTo(self.dayLabel.snp.width)
        }

        self.addSubview(self.dayLabelUnderBar)
        self.dayLabelUnderBar.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(self.dayLabel.snp.width)
            make.top.equalTo(self.dayLabel.snp.bottom)
            make.centerX.equalTo(self.dayLabel.snp.centerX)
        }

        self.addSubview(self.monthLabel)
        self.monthLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.dayLabel.snp.centerY)
            make.leading.equalTo(self.dayLabel.snp.trailing).offset(5)
            make.width.equalTo(self.snp.width).dividedBy(7.0)
            make.height.equalTo(self.monthLabel.snp.width)
        }
        
        self.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindUI() {
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    private func configureFont() {
        self.dayLabel.font = .systemFont(ofSize: 100)
        self.monthLabel.font = .systemFont(ofSize: 100)
    }
    
    func displayRawPage(with rawPageEntityPublisher: AnyPublisher<RawPageEntity, Error>) {
        self.rawPageEntityPublisherCancellable?.cancel()
        self.diaryPageView.isHidden = true
        self.activityIndicator.startAnimating()
        self.rawPageEntityPublisherCancellable = rawPageEntityPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in return
            } receiveValue: { [weak self] rawPageEntity in
                self?.diaryPageView.components = rawPageEntity.components
                self?.diaryPageView.pageBackgroundColor = UIColor(cgColor: rawPageEntity.backgroundType.rawValue)
                self?.diaryPageView.isHidden = false
            }
    }
}

extension DiaryCollectionViewCell: DiaryPageViewDelegate {
    func diaryPageDrawDidFinish(_ diaryPageView: DiaryPageView) {
        self.activityIndicator.stopAnimating()
    }
}
