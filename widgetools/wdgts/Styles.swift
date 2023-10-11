//
//  Styles.swift
//  wdgtsExtension
//
//  Created by leo on 2023-10-11.
//

import SwiftUI
import WidgetKit

struct WTLBtnStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

//#Preview {
//    Button(action: { print("Pressed") }) {
//        Image("star")
//            .font(.system(size: 28, weight: .semibold, design: .rounded))
//            .foregroundColor(.white)
//            .background(
//                Circle().fill().foregroundColor(.blue)
//                    .frame(width: 60, height: 60)
//                    .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
//            ).frame(width: 60, height: 60)
//    }
//    .buttonStyle(WTLBtnStyle())
//    .previewContext(WidgetPreviewContext(family: .systemMedium))
//}
