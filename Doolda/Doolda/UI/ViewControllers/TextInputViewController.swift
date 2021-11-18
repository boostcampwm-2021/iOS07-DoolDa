//
//  TextInputViewController.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/17.
//

import Combine
import UIKit

import SnapKit

protocol TextInputViewControllerDelegate: AnyObject {
    func textInputDidEndEditing(_ textComponentEntity: TextComponentEntity)
}

class TextInputViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var inputTextView: UITextView = {
        var textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.autocapitalizationType = .words
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textAlignment = .center
//        textView.layoutManager.allowsNonContiguousLayout = false
//        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.delegate = self
        return textView
    }()
    
    // MARK: - Private Properties
    
    private var widthRatioFromAbsolute: CGFloat?
    private var heightRatioFromAbsolute: CGFloat?
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: TextInputViewModel?
    private weak var delegate: TextInputViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(
        textInputViewModel: TextInputViewModel,
        delegate: TextInputViewControllerDelegate?,
        widthRatioFromAbsolute: CGFloat?,
        heightRatioFromAbsolute: CGFloat?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = textInputViewModel
        self.delegate = delegate
        self.widthRatioFromAbsolute = widthRatioFromAbsolute
        self.heightRatioFromAbsolute = heightRatioFromAbsolute
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configureCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureCommon()
    }
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
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
    
    // MARK: - Helpers
    
    private func configureCommon() {
        self.modalPresentationStyle = .overFullScreen
    }
    
    private func configureUI() {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        
        self.view.addSubview(self.inputTextView)
        self.inputTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.centerY)
        }
        self.inputTextView.becomeFirstResponder()
        
    }
    
    // MARK: - Private Methods

    private func computeSizeToAbsolute(with size: CGSize) -> CGSize {
        let computedWidth =  size.width / ( self.widthRatioFromAbsolute ?? 0.0 )
        let computedHeight = size.height / ( self.heightRatioFromAbsolute ?? 0.0 )
        return CGSize(width: computedWidth, height: computedHeight)
    }
}

extension TextInputViewController: UITextViewDelegate {
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
