//
//  PageDetailViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/24.
//

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
    
    // MARK: - Initializers
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
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
    
        self.view.addSubview(self.pageView)
        self.pageView.isUserInteractionEnabled = true
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
    
    private func configureFont() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]

    }

}
