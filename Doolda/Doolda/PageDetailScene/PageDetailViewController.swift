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
    
    private lazy var diaryPageView: DiaryPageView = {
        let view = DiaryPageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.delegate = self
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
    
    // MARK: - Initializers
    
    convenience init(viewModel: PageDetailViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.pageDetailViewWillAppear()
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
        self.title = DateFormatter.koreanFormatter.string(from: date)

        self.view.addSubview(self.diaryPageView)
        
        self.diaryPageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            make.width.equalTo(self.diaryPageView.snp.height).multipliedBy(17.0 / 30.0)
            let screenHeight = UIScreen.main.bounds.size.height
            if screenHeight > 750 {
                make.height.equalTo(self.view.safeAreaLayoutGuide).offset(-80)
            } else {
                make.height.equalTo(self.view.safeAreaLayoutGuide).offset(-45)
            }
        }
        
        self.diaryPageView.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.view.addSubview(self.shareButton)
        self.shareButton.snp.makeConstraints { make in
            make.top.equalTo(self.diaryPageView.snp.bottom).offset(5)
            make.leading.equalTo(self.diaryPageView.snp.leading)
            make.width.equalTo(30)
            make.height.equalTo(self.shareButton.snp.width)
        }
        
        self.view.addSubview(self.editPageButton)
        self.editPageButton.snp.makeConstraints { make in
            make.top.equalTo(self.diaryPageView.snp.bottom).offset(5)
            make.trailing.equalTo(self.diaryPageView.snp.trailing)
            make.width.equalTo(30)
            make.height.equalTo(self.editPageButton.snp.width)
        }

        self.editPageButton.isEnabled = self.viewModel.isPageEditable()
        self.activityIndicator.startAnimating()
    }
    
    private func bindUI() {
        self.shareButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.savePageAndShare()
            }
            .store(in: &self.cancellables)

        self.editPageButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.editPageButtonDidTap()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    private func bindViewModel() {
        self.viewModel.rawPageEntityPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rawPageEntity in
                self?.diaryPageView.pageBackgroundColor = UIColor(cgColor: rawPageEntity.backgroundType.rawValue)
                self?.diaryPageView.components = rawPageEntity.components
            }.store(in: &self.cancellables)
    }
    
    private func savePageAndShare() {
        UIGraphicsBeginImageContext(self.diaryPageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.diaryPageView.layer.render(in: context)
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    }
}

extension PageDetailViewController: DiaryPageViewDelegate {
    func diaryPageDrawDidFinish(_ diaryPageView: DiaryPageView) {
        self.activityIndicator.stopAnimating()
    }
}
