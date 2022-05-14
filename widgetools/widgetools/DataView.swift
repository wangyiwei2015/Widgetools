//
//  DataView.swift
//  widgetools
//
//  Created by wyw on 2022/5/14.
//

import SwiftUI

struct DataView: View {
    
    @State var counters: [String] = ud.dictionaryRepresentation()
        .keys.filter({$0.prefix(9) == "_counter_"})
    @State var canvases: [String] = ud.dictionaryRepresentation()
        .keys.filter({$0.prefix(8) == "_canvas_"})
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                Section {
                    ForEach(counters, id: \.self) {counterKey in
                        Text(counterKey).padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill().foregroundColor(.white)
                                    .shadow(radius: 2, y: 2)
                            )
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        ud.removeObject(forKey: counterKey)
                                        counters = ud.dictionaryRepresentation()
                                            .keys.filter({$0.prefix(9) == "_counter_"})
                                    }
                                } label: {Label("delete", systemImage: "trash")}
                            }
                    }
                } header: {
                    Text("Counter data").font(.title)
                }
                
                Spacer(minLength: 20)
                Divider()
                Spacer(minLength: 20)

                Section {
                    ForEach(canvases, id: \.self) {canvasKey in
                        Text(canvasKey).padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill().foregroundColor(.white)
                                    .shadow(radius: 2, y: 2)
                            )
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        ud.removeObject(forKey: canvasKey)
                                        canvases = ud.dictionaryRepresentation()
                                            .keys.filter({$0.prefix(8) == "_canvas_"})
                                    }
                                } label: {Label("delete", systemImage: "trash")}
                            }
                    }
                } header: {
                    Text("Canvas data").font(.title)
                }
                
            }.padding()
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
