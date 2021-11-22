//
//  SettingsViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import Combine
import UIKit

import SnapKit

class SettingsViewController: UIViewController {

    // MARK: - Subviews

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.left, for: .normal)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "설정"
        self.navigationController?.navigationBar.barTintColor = .dooldaLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension SettingsViewController: UITableViewDelegate {

}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // FIXME: ViewModel로부터 indexPath의 타이틀 정보, 우측 텍스트 정보를 받아와야 함
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsTableViewCell.identifier,
            for: indexPath
        ) as? SettingsTableViewCell else { return UITableViewCell() }
        let rightItem = UIImageView(image: .right)
        cell.configure(title: "설정", rightItem: rightItem)
        return cell
    }
}
