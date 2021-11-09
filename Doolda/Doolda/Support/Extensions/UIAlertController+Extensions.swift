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
    
    static func cancelEditPageAlert(cancelAction: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "편집 나가기",
            message: "페이지를 저장하지 않고 나갈 시, 작성한 내용은 저장되지 않습니다.",
            preferredStyle: .alert
        )
        let refreshAlertAction = UIAlertAction(title: "취소", style: .default)
        let exitAlertAction = UIAlertAction(title: "나가기", style: .destructive, handler: cancelAction)

        alert.addAction(refreshAlertAction)
        alert.addAction(exitAlertAction)
        return alert
    }
}
