//
//  ContentView.swift
//  widgetools
//
//  Created by wyw on 2022/5/12.
//

import SwiftUI
import Transparency

struct ContentView: View {
    
    @State var tab: Int = 0
    
    @State var bgBright: UIImage? = try? UIImage(data: Data(contentsOf: URL(fileURLWithPath: "\(wallPath)/imgB.jpg")))
    @State var bgDark: UIImage? = try? UIImage(data: Data(contentsOf: URL(fileURLWithPath: "\(wallPath)/imgD.jpg")))
    @State var isPickingLight = true
    @State var showsPicker = false
    @State var showsHelp = false
    @State var errAlert = false
    
    let bgGen = WidgetBackground()
    
    var body: some View {
        TabView(selection: $tab) {
            Text("WidgeTools").font(.title).foregroundColor(.gray)
                .tag(0).tabItem({Label("Title", systemImage: "swift")})
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
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
                    Text(ud.string(forKey: "last_cmd") ?? "None last cmd")
                }.padding()
            }.tag(1).tabItem({Label("Data", systemImage: "doc")})
            
            VStack {
                HStack {
                    LightModeWallpaper
                        //.shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
                    DarkModeWallpaper
                        //.shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
                }.padding([.bottom, .horizontal])
            }.tag(2).tabItem({Label("Config", systemImage: "gearshape")})
        }
        .sheet(isPresented: $showsPicker, onDismiss: updateWallpaperSave) {
            ImagePicker(
                isLightImg: $isPickingLight, imgL: $bgBright, imgD: $bgDark
            )
        }
        .alert("_invalid_wall", isPresented: $errAlert, actions: {Button("Dismiss"){}})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
