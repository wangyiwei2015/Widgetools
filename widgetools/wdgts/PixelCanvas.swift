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
    var canvasData: UInt64
    @Environment(\.widgetFamily) var widgetFamily
    
    init(canvasID: String) {
        self.canvasID = canvasID
        self.canvasData = (ud.object(forKey: "_canvas_\(canvasID)") ?? UInt64(0)) as! UInt64
    }
    
    let width = 8
    var height: Int {
        widgetFamily == .systemMedium ? 4 : 8
    }
    
    var body: some View {
        GeometryReader {geo in
            let w: CGFloat = (geo.size.width - 20) / 10
            VStack(spacing: 2) {
                ForEach(0..<height, id: \.self) {row in
                    HStack(spacing: 2) {
                        ForEach(0..<width, id: \.self) {col in
                            let pos = row * width + col
                            Link(destination: URL(string: "canvas/\(canvasID)/\(pos)")!) {
                                Circle().fill().foregroundColor(.blue)
                                    .frame(width: w, height: w)
                                    .opacity(canvasData & (1 << pos) > 0 ? 1 : 0.1)
                            }.frame(width: w, height: w)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.widgetURL(URL(string: "return/0")!)
    }
}

struct WTCanvas: Widget {
    let kind: String = "com.wyw.widgetools.widget.canvas"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CanvasProvider.Intent.self,
            provider: CanvasProvider()
        ) {entry in WGCanvasView(
            canvasID: hashSHA256(entry.configuration.uniqueTitle ?? "default")
        )}
        .configurationDisplayName(localized("canvas_name"))
        .description(localized("canvas_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        WGCanvasView(
            canvasID: hashSHA256("default")
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
