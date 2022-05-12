//
//  CounterView.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI
import WidgetKit

struct CounterView: View {
    
    var dataID: String
    var showBadge: String?
    @State var counter: Int
    
    init(dataID: String, showBadge: String?) {
        self.showBadge = showBadge
        self.dataID = dataID
        counter = ud.integer(forKey: "_counter_\(dataID)")
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(dataID)")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.gray)
                if let badge = showBadge {
                    Text(badge).foregroundColor(.blue)
                }
            }
            
            HStack {
                Link(destination: URL(string: "counter/\(dataID)/dec")!) {
                    Image(systemName: "minus")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .background(
                            Circle().fill().foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                        )
                }.frame(width: 60, height: 60)
                Spacer()
                Text("\(counter)")
                    .font(.system(size: 40, weight: .regular, design: .monospaced))
                Spacer()
                Link(destination: URL(string: "counter/\(dataID)/inc")!) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .background(
                            Circle().fill().foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                        )
                }.frame(width: 60, height: 60)
            }
        }.padding(.horizontal)
    }
}

struct CounterPreviews: PreviewProvider {
    static var previews: some View {
        CounterView(
            dataID: "temp", showBadge: "+1"
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
