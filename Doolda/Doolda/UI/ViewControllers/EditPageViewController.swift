//
//  EditPageViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

import SnapKit

class EditPageViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var scrollView: UIScrollView = UIScrollView()
    private lazy var contentView: UIView = UIView()
    
    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        var barButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private lazy var saveBarButtonItem: UIBarButtonItem = {
        var barButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private lazy var pageView: UIView = {
        var view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var addPhotoComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        return button
    }()
    
    private lazy var addTextComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "textformat"), for: .normal)
        return button
    }()
    
    private lazy var addStickerComponentButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        return button
    }()
    
    private lazy var changeBackgroundTypeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: .zero, y: .zero, width: 24, height: 24))
        button.setImage(UIImage(systemName: "doc"), for: .normal)
        return button
    }()
    
    private lazy var componentsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.addPhotoComponentButton,
                self.addTextComponentButton,
                self.addStickerComponentButton,
                self.changeBackgroundTypeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: EditPageViewModelProtocol?
    
    // MARK: - Initializers
    
    convenience init(viewModel: EditPageViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Dovemayo", size: 17) as Any]
        self.title = "새 페이지"
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem

        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.centerY.equalToSuperview().priority(.low)
        }
        
        self.contentView.addSubview(self.pageView)
        self.pageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(16)
            make.height.equalTo(self.pageView.snp.width).multipliedBy(30.0/17.0)
        }
        
        self.contentView.addSubview(self.componentsStackView)
        self.componentsStackView.snp.makeConstraints { make in
            make.leading.equalTo(self.pageView)
            make.top.equalTo(self.pageView.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-28)
            make.width.equalTo(135)
        }
    }
        
    private func bindUI() {
        guard let viewModel = self.viewModel else { return }
    }
    // MARK: - Private Methods
}
