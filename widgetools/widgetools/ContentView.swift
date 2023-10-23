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
    @State var showsAbout = false
    
    @State var bgBright: UIImage? = try? UIImage(data: Data(contentsOf: URL(fileURLWithPath: "\(wallPath)/imgB.jpg")))
    @State var bgDark: UIImage? = try? UIImage(data: Data(contentsOf: URL(fileURLWithPath: "\(wallPath)/imgD.jpg")))
    @State var isPickingLight = true
    @State var showsPicker = false
    //@State var showsHelp = false
    @State var errAlert = false
    
    @State var counterData = ud.dictionaryRepresentation().keys.filter({$0.prefix(9) == "_counter_"}).items
    @State var canvasData = ud.dictionaryRepresentation().keys.filter({$0.prefix(8) == "_canvas_"}).items
    
    //@AppStorage("_HAS_LAUNCHED") var hasLaunched: Bool = false
    
    let bgGen = WidgetBackground()
    
    var body: some View {
        TabView(selection: $tab) {
            VStack {
                Spacer()
                Text("WidgeTools").font(.title).foregroundColor(.gray)
                Text("v\(ver) (\(build))").foregroundColor(.gray)
                Button("About") {showsAbout = true}.bold().padding()
                Spacer()
                Button("Go Home") {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                }.buttonStyle(.borderedProminent).tint(.gray).offset(y: -50)
            }.tag(0).tabItem({Label("Title", systemImage: "swift")})
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Text("ctxt_del_info")
                    ForEach(counterData, id: \.self) {counterKey in
                        Text(counterKey).foregroundColor(.gray).contextMenu {
                            Button {
                                ud.removeObject(forKey: counterKey)
                                refreshUD()
                            } label: {Label("Delete", systemImage: "trashbin.fill")}
                        }
                    }
                    ForEach(canvasData, id: \.self) {canvasKey in
                        Text(canvasKey).foregroundColor(.gray).contextMenu {
                            Button {
                                ud.removeObject(forKey: canvasKey)
                                refreshUD()
                            } label: {Label("Delete", systemImage: "trashbin.fill")}
                        }
                    }
                    //Text(ud.string(forKey: "last_cmd") ?? "None last cmd")
                }.padding()
            }.tag(1).tabItem({Label("Data", systemImage: "doc")})
            
            VStack {
                Text("set_wall").font(.title)
                Text("set_wall_tutorial").font(.title3)
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
        .onAppear() {refreshUD()}
        .sheet(isPresented: $showsAbout) {
            VStack {
                Text("About").font(.title).bold()
                    .padding()
                Text("Version \(ver), build \(build)\n\n_INFO")
                    .padding()
                Spacer()
                Group {
                    Button {UIApplication.shared.open(URL(string: "https://github.com/wangyiwei2015/Widgetools")!)
                    } label: {
                        Label("Source code", systemImage: "chevron.left.forwardslash.chevron.right").bold()
                    }
                    Button {UIApplication.shared.open(URL(string: "mailto:wangyw.dev@outlook.com?subject=WidgeTools-Feedback&body=v\(ver)(\(build))\n================\n\n")!)
                    } label: {
                        Label("Email support", systemImage: "envelope").bold()
                    }.padding()
                    Button {UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/widgetools/id1634741840")!)
                    } label: {
                        Label("View on App Store", systemImage: "app.gift").bold()
                    }
                }.buttonStyle(.borderedProminent).tint(.gray)
            }.padding(.bottom)
        }
    }
    
    func refreshUD() {
        counterData = ud.dictionaryRepresentation().keys.filter({$0.prefix(9) == "_counter_"}).items
        canvasData = ud.dictionaryRepresentation().keys.filter({$0.prefix(8) == "_canvas_"}).items
    }
    
    let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String? ?? "0"
    let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String? ?? "0"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(tab: 0, showsAbout: false)
    }
}
