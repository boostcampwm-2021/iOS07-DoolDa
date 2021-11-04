//
//  DiaryViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/04.
//

import UIKit

import SnapKit

class DiaryViewController: UIViewController {

    let label: UILabel = {
        var label = UILabel()
        label.text = "다이어리 화면 🙆🏻‍♀️"
        label.font = UIFont(name: "Dovemayo", size: 18)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground

        self.view.addSubview(label)
        self.label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

}
