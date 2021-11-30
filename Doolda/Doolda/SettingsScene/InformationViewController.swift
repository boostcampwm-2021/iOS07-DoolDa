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

    // MARK: - Subviews

    private var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .dooldaLabel
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        return textView
    }()

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    // MARK: - Public Properties

    @Published var titleText: String?
    @Published var contentText: String?
    @Published var image: UIImage?

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.bindUI()
    }

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground

        self.view.addSubview(self.textView)
        self.textView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
        }

        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func bindUI() {
        self.$titleText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.navigationItem.title = title
            }
            .store(in: &self.cancellables)

        self.$contentText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contentText in
                self?.textView.text = contentText
            }
            .store(in: &self.cancellables)

        self.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &self.cancellables)
    }

}