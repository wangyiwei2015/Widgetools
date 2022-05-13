//
//  Utils.swift
//  widgetools
//
//  Created by wyw on 2022/5/12.
//

import Foundation
import CryptoKit

let ud = UserDefaults(suiteName: "group.com.wyw.widgetools")!
let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.wyw.widgetools")

func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func hashSHA256(_ input: String) -> String {
    SHA256.hash(
        data: Data(input.utf8)
    ).compactMap {
        String(format: "%02x", $0)
    }.joined()
}
