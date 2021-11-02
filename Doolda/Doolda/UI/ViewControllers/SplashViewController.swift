//
//  SplashViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

import SnapKit

final class SplashViewController: UIViewController {

    // MARK: - Publics Properties

    let backgroundImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage.hedgehogs
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "둘다"
        label.textColor = UIColor.dooldaLabel
        return label
    }()

    let subtitleLabel: UILabel = {
        var label = UILabel()
        label.text = "우리 둘만의 다이어리"
        label.textColor = UIColor.dooldaLabel
        return label
    }()
    
    // MARK: - Private Properties
    
    private var viewModel: SplashViewModel?
    
    // MARK: - Initializers
    
    convenience init(viewModel: SplashViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.height.equalTo(backgroundImage.snp.width)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }

}
