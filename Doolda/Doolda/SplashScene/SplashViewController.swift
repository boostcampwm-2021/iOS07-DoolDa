//
//  SplashViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

import SnapKit

final class SplashViewController: UIViewController {

    // MARK: - Subviews

    private lazy var backgroundImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage.hedgehogs
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "둘다"
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "우리 둘만의 다이어리"
        label.textColor = UIColor.dooldaLabel
        label.textAlignment = .center
        return label
    }()

    // MARK: - Private Properties
    
    private var viewModel: SplashViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(viewModel: SplashViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
        self.bindUI()
        self.viewModel?.applyGlobalFont()
        self.viewModel?.prepareUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Helpers
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground

        self.view.addSubview(backgroundImage)
        self.backgroundImage.snp.makeConstraints { make in
            make.height.equalTo(backgroundImage.snp.width)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }

        self.view.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(view.frame.height * 0.20)
        }

        self.view.addSubview(subtitleLabel)
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }
    }

    private func configureFont() {
        self.titleLabel.font = UIFont(name: FontType.dovemayo.name, size: 72)
        self.subtitleLabel.font = UIFont(name: FontType.dovemayo.name, size: 18)
    }

    private func bindUI() {
        self.viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard error != nil else { return }
                self?.presentNetworkAlert()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Private Methods
    private func presentNetworkAlert() {
        let alert = UIAlertController.networkAlert { _ in
            self.viewModel?.prepareUserInfo()
        }
        self.present(alert, animated: true)
    }
}
