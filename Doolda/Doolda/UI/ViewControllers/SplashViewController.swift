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

    let background: UIImageView = {
        var imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage.splashBackground
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
    }

    // MARK: - Helpers
    private func configureUI() {
        
    }

}
