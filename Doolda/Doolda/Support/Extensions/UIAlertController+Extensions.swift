//
//  UIAlertController+Extensions.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/08.
//

import UIKit

extension UIAlertController {
    static func networkAlert(refreshAction: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "네트워크 오류",
                                      message: "Wifi나 3G/LTE/5G를 연결 후 재시도 해주세요🙏",
                                      preferredStyle: .alert)
        let refreshAlertAction = UIAlertAction(title: "재시도", style: .default, handler: refreshAction)
        let exitAlertAction = UIAlertAction(title: "종료", style: .destructive) { _ in exit(0) }

        alert.addAction(refreshAlertAction)
        alert.addAction(exitAlertAction)
        return alert
    }
}
