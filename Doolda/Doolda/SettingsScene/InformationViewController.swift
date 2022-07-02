//
//  InformationViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import UIKit

import SnapKit

class InformationViewController: UIViewController {

    // MARK: - Modes

    enum DisplayMode {
        case text(content: String)
        case image(content: UIImage?)
    }

    // MARK: - Subviews

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .dooldaLabel
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        textView.contentInsetAdjustmentBehavior = .never
        return textView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = .zero
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private lazy var contentView = UIView()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Public Properties

    private let titleText: String
    private let mode: DisplayMode

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(titleText: String, mode: DisplayMode) {
        self.titleText = titleText
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = titleText

        switch mode {
        case let .text(content):
            self.view.addSubview(self.textView)
            self.textView.text = content
            self.textView.snp.makeConstraints { make in
                make.top.bottomMargin.equalTo(self.view.safeAreaLayoutGuide)
                make.leading.trailing.equalToSuperview().inset(16)
            }
        case let .image(content):
            self.view.addSubview(self.scrollView)
            self.scrollView.snp.makeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide)
                make.bottom.leading.trailing.equalToSuperview()
            }

            self.scrollView.addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.top.bottom.width.equalToSuperview()
            }

            self.contentView.addSubview(self.imageView)
            self.imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            imageView.image = content
        }
    }
}
