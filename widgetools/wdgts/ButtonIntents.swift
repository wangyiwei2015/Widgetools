//
//  ButtonIntents.swift
//  wdgtsExtension
//
//  Created by leo on 2023-09-21.
//

import SwiftUI
import AppIntents
import WidgetKit

@available(iOS 17, *)
struct ButtonIntent: AppIntent {
    static let title: LocalizedStringResource = "Button Actions"
    static let description = IntentDescription("On widget button tapped")
    
    init(_ actionLink: String) {
        self.link = actionLink
        //ud.set(actionLink, forKey: "last_cmd")
    }
    
    init() {
        self.link = "/"
        //ud.set("no action", forKey: "last_cmd")
    }
    
    @Parameter(title: "Action URL") var link: String
    
    func perform() async throws -> some IntentResult {
        let cmd = link.split(separator: "/")
        switch cmd[0] {
        case "counter":
            let counterID = String(cmd[1])
            let oldValue = ud.integer(forKey: "_counter_\(counterID)")
            let newValue = cmd[2] == "inc" ? oldValue + 1 : oldValue - 1
            ud.set(newValue, forKey: "_counter_\(counterID)")
            ud.set(cmd[2] == "inc" ? 1 : -1, forKey: "_counter_\(counterID)_op")
            WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.counter")
        case "randgen":
            if cmd[1] == "new" {
                WidgetCenter.shared.reloadTimelines(ofKind: "com.wyw.widgetools.widget.randgen")
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
        default: break
        }
        return .result()
    }
}
