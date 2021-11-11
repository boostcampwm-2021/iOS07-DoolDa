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

    static func defaultAlert(title: String?, message: String?, handler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: handler)

        alert.addAction(action)
        return alert
    }
    
    static func selectAlert(
        title: String,
        message: String,
        leftActionTitle: String,
        rightActionTitle: String,
        action: @escaping (UIAlertAction) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let cancelAlertAction = UIAlertAction(title: leftActionTitle, style: .default)
        let saveAlertAction = UIAlertAction(title: rightActionTitle, style: .destructive, handler: action)

        alert.addAction(cancelAlertAction)
        alert.addAction(saveAlertAction)
        return alert
    }
}
