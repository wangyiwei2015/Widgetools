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
                    case "return":
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    case "counter":
                        let counterID = String(cmd[1])
                        let oldValue = ud.integer(forKey: "_counter_\(counterID)")
                        let newValue = cmd[2] == "inc" ? oldValue + 1 : oldValue - 1
                        ud.set(newValue, forKey: "_counter_\(counterID)")
                        ud.set(cmd[2] == "inc" ? 1 : -1, forKey: "_counter_\(counterID)_op")
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.counter")
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    case "randgen":
                        if cmd[1] == "new" {
                            WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.randgen")
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    case "canvas":
                        let canvasID = String(cmd[1])
                        let targetColor = ud.integer(forKey: "_canvas_\(canvasID)_cfg")
                        let oldValue1 = (ud.object(forKey: "_canvas_\(canvasID)_1") ?? UInt64(0)) as! UInt64
                        let oldValue2 = (ud.object(forKey: "_canvas_\(canvasID)_2") ?? UInt64(0)) as! UInt64
                        switch targetColor {
                        case 0: //blue
                            let newValue1: UInt64 = oldValue1 | (1 << UInt64(cmd[2])!)
                            let newValue2: UInt64 = oldValue2 & ~(1 << UInt64(cmd[2])!)
                            ud.set(newValue1, forKey: "_canvas_\(canvasID)_1")
                            ud.set(newValue2, forKey: "_canvas_\(canvasID)_2")
                        case 1: //red
                            let newValue1: UInt64 = oldValue1 & ~(1 << UInt64(cmd[2])!)
                            let newValue2: UInt64 = oldValue2 | (1 << UInt64(cmd[2])!)
                            ud.set(newValue1, forKey: "_canvas_\(canvasID)_1")
                            ud.set(newValue2, forKey: "_canvas_\(canvasID)_2")
                        case 2: //green
                            let newValue1: UInt64 = oldValue1 | (1 << UInt64(cmd[2])!)
                            let newValue2: UInt64 = oldValue2 | (1 << UInt64(cmd[2])!)
                            ud.set(newValue1, forKey: "_canvas_\(canvasID)_1")
                            ud.set(newValue2, forKey: "_canvas_\(canvasID)_2")
                        default: //eraser
                            let newValue1: UInt64 = oldValue1 & ~(1 << UInt64(cmd[2])!)
                            let newValue2: UInt64 = oldValue2 & ~(1 << UInt64(cmd[2])!)
                            ud.set(newValue1, forKey: "_canvas_\(canvasID)_1")
                            ud.set(newValue2, forKey: "_canvas_\(canvasID)_2")
                        }
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.canvas")
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    case "canvasctrl":
                        let canvasID = String(cmd[1])
                        if(cmd[2] == "clear") {
                            ud.set(UInt64(0), forKey: "_canvas_\(canvasID)_1")
                            ud.set(UInt64(0), forKey: "_canvas_\(canvasID)_2")
                            WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.canvas")
                        } else {
                            let selectedColor = Int(String(cmd[2])) ?? 0 // (any other) erase, 0 blue, 1 red, 2 green
                            ud.set(selectedColor, forKey: "_canvas_\(canvasID)_cfg")
                        }
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.canvasctrl")
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    default: break
                    }
                }
        }
    }
}
