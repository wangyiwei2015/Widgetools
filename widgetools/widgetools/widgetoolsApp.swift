//
//  widgetoolsApp.swift
//  widgetools
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI
import WidgetKit

@main
struct widgetoolsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL {url in
                    let cmd = url.absoluteString.split(separator: "/")
                    switch cmd[0] {
                    case "counter":
                        let oldValue = ud.integer(forKey: "_counter_\(cmd[1])")
                        let newValue = cmd[2] == "inc" ? oldValue + 1 : oldValue - 1
                        ud.set(newValue, forKey: "_counter_\(cmd[1])")
                        ud.set(cmd[2] == "inc" ? 1 : -1, forKey: "_counter_\(cmd[1])_op")
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.counter")
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    case "randgen":
                        if cmd[1] == "new" {
                            WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.randgen")
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    default: break
                    }
                }
        }
    }
}
