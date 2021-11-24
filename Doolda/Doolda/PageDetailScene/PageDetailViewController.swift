//
//  PageDetailViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/24.
//

import Combine
import UIKit

class PageDetailViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var pageView: UIView = {
        var view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var shareButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.squareAndArrowUp, for: .normal)
        return button
    }()
    
    private lazy var editPageButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(.squareAndPencil, for: .normal)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        return activityIndicator
    }()
    
    // MARK: - Private Properties

    private var viewModel: PageDetailViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []
    
    private var widthRatioFromAbsolute: CGFloat {
        return self.pageView.frame.width / 1700.0
    }
    
    private var heightRatioFromAbsolute: CGFloat {
        return self.pageView.frame.height / 3000.0
    }
    
    // MARK: - Initializers
    
    convenience init(viewModel: PageDetailViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.pageDetailViewWillAppear()
        self.configureFont()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        guard let navigationController = self.navigationController else { return }

        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.tintColor = .dooldaLabel
        navigationController.navigationBar.topItem?.title = ""
        self.navigationItem.backButtonTitle = ""
        
        let date = self.viewModel.getDate()
        self.title = DateFormatter.koreanFormatter.string(from: date) ?? "둘다"

        self.view.addSubview(self.pageView)
        self.pageView.clipsToBounds = true
        self.pageView.layer.cornerRadius = 4
        
        self.pageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            make.width.equalTo(self.pageView.snp.height).multipliedBy(17.0 / 30.0)
            let screenHeight = UIScreen.main.bounds.size.height
            if screenHeight > 750 {
                make.height.equalTo(self.view.safeAreaLayoutGuide).offset(-80)
            } else {
                make.height.equalTo(self.view.safeAreaLayoutGuide).offset(-45)
            }
        }
        
        self.pageView.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.view.addSubview(self.shareButton)
        self.shareButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageView.snp.bottom).offset(5)
            make.leading.equalTo(self.pageView.snp.leading)
            make.width.equalTo(30)
            make.height.equalTo(self.shareButton.snp.width)
        }
        
        self.view.addSubview(self.editPageButton)
        self.editPageButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageView.snp.bottom).offset(5)
            make.trailing.equalTo(self.pageView.snp.trailing)
            make.width.equalTo(30)
            make.height.equalTo(self.editPageButton.snp.width)
        }
    }
    
    private func bindUI() {
        self.shareButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.savePageAndShare()
            }.store(in: &self.cancellables)
    }
    
    private func bindViewModel() {
        self.activityIndicator.startAnimating()
        self.viewModel.rawPageEntityPublisher
            .sink { [weak self] rawPageEntity in
                guard let rawPageEntity = rawPageEntity,
                      let self = self else { return }
                self.drawPage(with: rawPageEntity)
            }.store(in: &self.cancellables)
    }
    
    private func drawPage(with rawPage: RawPageEntity) {
        self.pageView.subviews.forEach { $0.removeFromSuperview() }
        
        self.pageView.backgroundColor = UIColor(cgColor: rawPage.backgroundType.rawValue)
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
    
    private func savePageAndShare() {
        UIGraphicsBeginImageContext(self.pageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.pageView.layer.render(in: context)
        if let pageImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            
            var imagesToShare = [AnyObject]()
            imagesToShare.append(pageImage)
            
            let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func configureFont() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
    }
}
