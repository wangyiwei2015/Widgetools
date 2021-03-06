//
//  WidgetsMian.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI
import WidgetKit

@main
struct WTWGext: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WTCounter() // 计数器
        // 快速计时
        WTRandgen() // 随机数生成
        WTCanvas() // 像素绘图板
        WTCanvasControl() // 画板设置
    }
}
