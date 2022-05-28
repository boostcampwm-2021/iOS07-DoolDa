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
        label.font = UIFont(name: FontType.dovemayo.name, size: 72)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "우리 둘만의 다이어리"
        label.textColor = UIColor.dooldaLabel
        label.font = UIFont(name: FontType.dovemayo.name, size: 18)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Private Properties
    
    private var viewModel: SplashViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(viewModel: SplashViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in self?.viewModel.validateAccount() }
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

    private func bindUI() {
        self.viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard error != nil else { return }
                self?.showErrorAlert()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods
    
    private func showErrorAlert() {
        let alert = UIAlertController.networkAlert { _ in
            self.viewModel.validateAccount()
        }
        self.present(alert, animated: true)
    }
}
