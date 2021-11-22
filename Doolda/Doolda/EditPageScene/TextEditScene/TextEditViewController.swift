//
//  TextEditViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import Combine
import UIKit

import SnapKit

protocol TextEditViewControllerDelegate: AnyObject {
    func textInputDidEndEditing(_ textComponentEntity: TextComponentEntity)
}

class TextEditViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var inputTextView: UITextView = {
        var textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.autocapitalizationType = .words
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.delegate = self
        return textView
    }()
    
    // MARK: - Private Properties
    
    private var widthRatioFromAbsolute: CGFloat?
    private var heightRatioFromAbsolute: CGFloat?
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: TextEditViewModelProtocol?
    private weak var delegate: TextEditViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(
        textEditViewModel: TextEditViewModelProtocol,
        delegate: TextEditViewControllerDelegate?,
        widthRatioFromAbsolute: CGFloat?,
        heightRatioFromAbsolute: CGFloat?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = textEditViewModel
        self.delegate = delegate
        self.widthRatioFromAbsolute = widthRatioFromAbsolute
        self.heightRatioFromAbsolute = heightRatioFromAbsolute
        self.modalPresentationStyle = .overFullScreen
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        
        self.view.addSubview(self.inputTextView)
        self.inputTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.centerY)
        }
        self.inputTextView.becomeFirstResponder()
    }
    
    private func bindUI() {
        self.view.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                guard let self = self,
                      let textComponenetEntity = self.viewModel?.inputViewEditingDidEnd(
                        input: self.inputTextView.text,
                        contentSize: self.computeSizeToAbsolute(with: self.inputTextView.contentSize),
                        fontSize: 16,
                        color: .black
                      ) else { return }
                self.delegate?.textInputDidEndEditing(textComponenetEntity)
                self.dismiss(animated: false)
            }.store(in: &self.cancellables)
    }
    
    // MARK: - Private Methods

    private func computeSizeToAbsolute(with size: CGSize) -> CGSize {
        let computedWidth =  size.width / ( self.widthRatioFromAbsolute ?? 0.0 )
        let computedHeight = size.height / ( self.heightRatioFromAbsolute ?? 0.0 )
        return CGSize(width: computedWidth, height: computedHeight)
    }
}

extension TextEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = "내용을 입력하세요"
        textView.textColor = .darkGray
        textView.sizeToFit()
        textView.snp.makeConstraints { make in
            make.width.equalTo(textView.contentSize.width)
            make.height.equalTo(textView.contentSize.height)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .darkGray,
           let input = textView.text.last {
            textView.textColor = .black
            textView.text = String(input)
        } else if textView.textColor == .black, textView.text.isEmpty {
            textView.textColor = .darkGray
            textView.text = "내용을 입력하세요"
        }
        let maximumWidth: CGFloat = self.view.frame.width - 40
        let newSize = textView.sizeThatFits(CGSize(width: maximumWidth, height: CGFloat.greatestFiniteMagnitude))
        
        textView.snp.updateConstraints { make in
            make.width.equalTo(newSize.width)
            make.height.equalTo(newSize.height)
        }
    }
}
