//
//  FontPickerViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/23.
//

import Combine
import UIKit

import SnapKit

protocol FontPickerViewControllerDelegate: AnyObject {
    func fontDidSelect(_ font: FontType)
}

class FontPickerViewController: BottomSheetViewController {

    // MARK: - Subviews

    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.text = "폰트 설정"
        label.textAlignment = .center
        return label
    }()

    private lazy var fontPicker: UIPickerView = {
        let fontPicker = UIPickerView()
        fontPicker.backgroundColor = .clear
        return fontPicker
    }()

    private lazy var applyButton: UIButton = {
        let button = DooldaButton()
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.setTitle("적용", for: .normal)
        return button
    }()

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []
    private weak var delegate: FontPickerViewControllerDelegate?

    // MARK: - Initializers

    convenience init(delegate: FontPickerViewControllerDelegate?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontPicker.delegate = self
        self.fontPicker.dataSource = self
        self.configureUI()
        self.configureFont()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.body.backgroundColor = .dooldaBackground

        self.body.addSubview(self.bottomSheetTitle)
        self.bottomSheetTitle.snp.makeConstraints { make in
            make.top.equalTo(self.body).offset(16)
            make.leading.equalTo(self.body).offset(16)
            make.trailing.equalTo(self.body).offset(-16)
            make.height.equalTo(20)
        }

        self.body.addSubview(self.fontPicker)
        self.fontPicker.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.bottomSheetTitle)
            make.top.equalTo(self.bottomSheetTitle.snp.bottom).offset(8)
            make.height.equalTo(162)
        }

        self.body.addSubview(self.applyButton)
        self.applyButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.bottomSheetTitle)
            make.top.equalTo(self.fontPicker.snp.bottom).offset(8)
            make.height.equalTo(44)
        }

        self.detent = .custom(292)
    }

    private func configureFont() {
        self.bottomSheetTitle.font = .systemFont(ofSize: 16)
    }

    private func bindUI() {
        self.applyButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let index = self?.fontPicker.selectedRow(inComponent: 0),
                      let font = FontType.allCases[exist: index] else { return }
                self?.delegate?.fontDidSelect(font)
            }
            .store(in: &self.cancellables)
    }

}

extension FontPickerViewController: UIPickerViewDelegate {

}

extension FontPickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FontType.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self.body.frame.height / 8
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard let fontName = FontType.allCases[exist: row]?.name,
              let text = FontType.allCases[exist: row]?.displayName else { return UIView() }

        var pickerLabel = view as? UILabel
        if pickerLabel == nil { pickerLabel = UILabel() }
        pickerLabel?.text = text
        pickerLabel?.font = UIFont(name: fontName, size: 28)
        pickerLabel?.textAlignment = .center
        return pickerLabel ?? UIView()
    }
}
