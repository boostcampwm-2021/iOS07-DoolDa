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
        self.viewModel?.prepareUserInfo()
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
        self.titleLabel.font = UIFont(name: "Dovemayo", size: 72)
        self.subtitleLabel.font = UIFont(name: "Dovemayo", size: 18)
    }

    private func bindUI() {
        self.viewModel?.$error
            .receive(on: DispatchQueue.main)
            .sink { error in
                guard let _ = error else { return }
                self.presentNetworkAlert()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods
    private func presentNetworkAlert() {
        let alert = UIAlertController(title: "네트워크 오류",
                                      message: "Wifi나 3G/LTE/5G를 연결 후 재시도 해주세요🙏",
                                      preferredStyle: .alert)
        let refreshAction = UIAlertAction(title: "재시도", style: .default) { _ in
            self.viewModel?.prepareUserInfo()
            print("재시도")
        }
        let exitAction = UIAlertAction(title: "종료", style: .destructive) { _ in
            exit(0)
        }

        alert.addAction(exitAction)
        alert.addAction(refreshAction)
        self.present(alert, animated: true)
    }

}
