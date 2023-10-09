//
//  PixelCanvas.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/13.
//

import WidgetKit
import SwiftUI
import Intents

struct CanvasProvider: IntentTimelineProvider {
    typealias Entry = CanvasEntry
    typealias Intent = CanvasConfigIntent
    
    func placeholder(in context: Context) -> CanvasEntry {
        CanvasEntry(date: Date(), configuration: Intent())
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (CanvasEntry) -> ()) {
        let entry = CanvasEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [
            CanvasEntry(date: Date(), configuration: configuration)
        ], policy: .never)
        completion(timeline)
    }
}

struct CanvasEntry: TimelineEntry {
    let date: Date
    let configuration: CanvasProvider.Intent
}

struct WGCanvasView: View {
    var canvasID: String
    var canvasData1: UInt64
    var canvasData2: UInt64
    var pos: HomeScreenPosition?
    var background: UIImage? {
        if let pos = pos {
            let colorChar = colorScheme == .light ? "B" : "D"
            var imgID = 0
            switch widgetFamily {
            case .systemSmall:
                imgID = pos.rawValue
            case .systemMedium:
                imgID = Int((pos.rawValue + 1) / 2) + 6
            case .systemLarge:
                imgID = pos.rawValue > 3 ? 11 : 10
            default: break
            }
            return try? UIImage(data: Data(contentsOf: URL(
                fileURLWithPath: "\(wallPath)/img\(colorChar)\(imgID).jpg"
            )))
        }
        return nil
    }
    
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    init(canvasID: String, pos: HomeScreenPosition?) {
        self.canvasID = canvasID
        self.canvasData1 = (ud.object(forKey: "_canvas_\(canvasID)_1") ?? UInt64(0)) as! UInt64
        self.canvasData2 = (ud.object(forKey: "_canvas_\(canvasID)_2") ?? UInt64(0)) as! UInt64
        self.pos = pos
    }
    
    let width = 8
    var height: Int {
        widgetFamily == .systemMedium ? 4 : 8
    }
    
    let staticColors: [Color] = [Color(UIColor(white: 0, alpha: 0.1)), .blue, .red, .green]
    func color(of pos: Int) -> Color {
        let d1 = canvasData1 & (1 << pos) > 0 ? 1 : 0
        let d2 = canvasData2 & (1 << pos) > 0 ? 2 : 0
        return staticColors[d1 + d2]
    }
    
    var body: some View {
        ZStack {
            if let wallpaperClip = background {
                Image(uiImage: wallpaperClip).resizable()
            }
            //Color(UIColor.systemBackground).opacity(0.3)
            GeometryReader {geo in
                let w: CGFloat = (geo.size.width - 20) / 10
                VStack(spacing: 2) {
                    ForEach(0..<height, id: \.self) {row in
                        HStack(spacing: 2) {
                            //ForEach(0..<width, id: \.self) {col in
                                //let pos = row * width + col
                                if #available(iOS 17, *) {
                                    ForEach(0..<width, id: \.self) {col in
                                        let pos = row * width + col
                                        Button(intent: ButtonIntent("canvas/\(canvasID)/\(pos)")) {
                                            Circle().fill().foregroundColor(color(of: pos))
                                                .frame(width: w, height: w)
                                        }.frame(width: w, height: w)
                                        .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 1, y: 1)
                                    }
                                } else {
                                    ForEach(0..<width, id: \.self) {col in
                                        let pos = row * width + col
                                        Link(destination: URL(string: "canvas/\(canvasID)/\(pos)")!) {
                                            Circle().fill().foregroundColor(color(of: pos))
                                                .frame(width: w, height: w)
                                        }.frame(width: w, height: w)
                                        .shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 1, y: 1)
                                    }
                                }
                                //.shadow(color: Color(UIColor(white: 0, alpha: 0.6)), radius: 1, y: 1)
                            //}
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }.widgetURL(URL(string: "return/0")!)
        }
    }
}

struct WTCanvas: Widget {
    let kind: String = "com.wyw.widgetools.widget.canvas"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CanvasProvider.Intent.self,
            provider: CanvasProvider()
        ) {entry in WGCanvasView(
            canvasID: hashSHA256(entry.configuration.uniqueTitle ?? "default"),
            pos: entry.configuration.transparent == 1 ? entry.configuration.position : nil
        )}
        .configurationDisplayName(localized("canvas_name"))
        .description(localized("canvas_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        WGCanvasView(
            canvasID: hashSHA256("default"), pos: nil
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
