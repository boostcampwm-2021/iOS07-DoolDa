//
//  Secrets.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/22.
//

import Foundation

enum Secrets {
    static let fcmServerKey = Bundle.main.infoDictionary?["FCM_SERVER_KEY"] as? String
}
