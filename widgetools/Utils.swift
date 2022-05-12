//
//  Utils.swift
//  widgetools
//
//  Created by wyw on 2022/5/12.
//

import Foundation

let ud = UserDefaults(suiteName: "group.com.wyw.widgetools")!
let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.wyw.widgetools")

func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}
