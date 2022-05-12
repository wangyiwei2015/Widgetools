//
//  RandgenView.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI
import WidgetKit

struct RandgenView: View {
    var isSmallWidget: Bool
    var number: Int?
    
    var body: some View {
        if isSmallWidget {
            VStack {
                if let result = number {
                    Text("\(result)").padding()
                        .font(.system(size: 30, weight: .semibold))
                } else {
                    Text("Config error").padding()
                        .font(.system(size: 20, weight: .semibold))
                }
                Text("Tap to re-generate")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }.widgetURL(URL(string: "randgen/new")!)
        } else {
            HStack {
                Spacer()
                if let result = number {
                    Text("\(result)")
                        .font(.system(size: 32, weight: .semibold))
                } else {
                    Text("Config error")
                        .font(.system(size: 32, weight: .semibold))
                }
                Spacer()
                Link(destination: URL(string: "randgen/new")!) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .background(
                            Circle().fill().foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                        )
                }.frame(width: 60, height: 60).padding(.trailing)
            }
        }
    }
}

struct RandgenView_Previews: PreviewProvider {
    static var previews: some View {
        RandgenView(isSmallWidget: true, number: 1234)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
