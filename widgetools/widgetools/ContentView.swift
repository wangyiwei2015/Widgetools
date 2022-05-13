//
//  ContentView.swift
//  widgetools
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("\(hashSHA256("文本"))").padding()
            Text(
                ud.dictionaryRepresentation().keys
                .filter({$0.prefix(9) == "_counter_"})
                .description
            )
            Text(
                ud.dictionaryRepresentation().keys
                .filter({$0.prefix(8) == "_canvas_"})
                .description
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
