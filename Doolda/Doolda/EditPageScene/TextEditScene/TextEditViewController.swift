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
    func textInputDidEndInput(_ textComponentEntity: TextComponentEntity)
    func textInputDidEndEditing(_ textComponentEntity: TextComponentEntity)
}

class TextEditViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var inputTextView: UITextView = {
        var textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.autocapitalizationType = .words
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.delegate = self
        return textView
    }()
    
    private lazy var fontColorView: FontColorPickerView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        let fontColorView = FontColorPickerView(
            frame: frame,
            collectionViewDelegate: self,
            collectionViewDataSource: self
        )
        return fontColorView
    }()
    
    private lazy var fontSizeControl: FontSizeControl = {
        let fontSizeControl = FontSizeControl(frame: CGRect(x: 0, y: .zero, width: 30, height: 300))
        return fontSizeControl
    }()
    
    // MARK: - Private Properties
    
    private var widthRatioFromAbsolute: CGFloat?
    private var heightRatioFromAbsolute: CGFloat?
    
    private var currentColorIndex: Int = 0 {
        didSet {
            guard let currentColor = self.viewModel.getFontColor(at: self.currentColorIndex) else { return }
            self.inputTextView.textColor = UIColor(cgColor: currentColor)
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: TextEditViewModelProtocol!
    private weak var delegate: TextEditViewControllerDelegate?
    
    override var inputAccessoryView: UIView? {
            return self.fontColorView
    }
    
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
        self.view.backgroundColor = .black.withAlphaComponent(0.7)
        
        self.view.addSubview(self.inputTextView)
        self.inputTextView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp.centerY)
        }
        self.inputTextView.becomeFirstResponder()
        
        self.view.addSubview(self.fontSizeControl)
        self.fontSizeControl.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.width.equalTo(30)
            make.bottom.equalTo(self.view.snp.centerY)
        }
 
    }
    
    private func bindUI() {
        self.view.publisher(for: UITapGestureRecognizer())
            .sink { [weak self] _ in
                guard let self = self,
                      let textComponenetEntity = self.viewModel?.inputViewEditingDidEnd(
                        input: self.inputTextView.text,
                        contentSize: self.computeSizeToAbsolute(with: self.inputTextView.contentSize),
                        fontSize: 18 * self.fontSizeControl.value,
                        colorIndex: self.currentColorIndex
                    ) else { return }
                if self.viewModel?.selectedTextComponent != nil {
                    self.delegate?.textInputDidEndEditing(textComponenetEntity)
                } else {
                    self.delegate?.textInputDidEndInput(textComponenetEntity)
                }
                self.dismiss(animated: false)
            }.store(in: &self.cancellables)
  
        self.fontSizeControl.publisher(for: .allTouchEvents)
            .sink { [weak self] control in
                guard let self = self ,
                      let fontsizeControl = control as? FontSizeControl else { return }
                self.inputTextView.font = .systemFont(ofSize: 18 * fontsizeControl.value)
                let maximumWidth: CGFloat = self.view.frame.width - 40
                let newSize = self.inputTextView.sizeThatFits(CGSize(width: maximumWidth, height: CGFloat.greatestFiniteMagnitude))
                
                self.inputTextView.snp.updateConstraints { make in
                    make.width.equalTo(newSize.width)
                    make.height.equalTo(newSize.height)
                }
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
        if let selectedTextComponent = self.viewModel?.selectedTextComponent {
            self.inputTextView.text = selectedTextComponent.text

        } else {
            textView.text = "내용을 입력하세요"
            textView.textColor = .systemGray
        }
        textView.sizeToFit()
        textView.snp.makeConstraints { make in
            make.width.equalTo(textView.contentSize.width)
            make.height.equalTo(textView.contentSize.height)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .systemGray,
           let input = textView.text.last {
            if !"내용을 입력하세요".contains(input) {
                textView.text = String(input)
            } else {
                textView.text = ""
            }
            textView.textColor = .black
        } else if textView.textColor == .black, textView.text.isEmpty {
            textView.textColor = .systemGray
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

extension TextEditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension TextEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = collectionView.frame.width / 2.0 - 15
        return UIEdgeInsets(top: 5, left: inset, bottom: 5, right: inset)
        }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            if let collectionView = scrollView as? UICollectionView {
                let cellCount = collectionView.numberOfItems(inSection: 0)
                let cellWidth: CGFloat = 45
                
                var offset = targetContentOffset.pointee
                let index = Int(round((offset.x + collectionView.contentInset.left) / cellWidth))
                
                if index > self.currentColorIndex {
                    self.currentColorIndex = index < cellCount ? index : cellCount - 1
                } else if index < self.currentColorIndex {
                    self.currentColorIndex = index > 0 ? index : 0
                }
                
                offset = CGPoint(x: CGFloat(self.currentColorIndex) * cellWidth - collectionView.contentInset.left, y: 0)
                targetContentOffset.pointee = offset
            }
        }
}

extension TextEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getFontColorCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FontColorCollectionViewCell.identifier,
            for: indexPath
        ) as? FontColorCollectionViewCell,
              let cellColor = self.viewModel.getFontColor(at: indexPath.item)
        else { return UICollectionViewCell() }

        cell.configure(with: UIColor(cgColor: cellColor))
        return cell
    }
}
