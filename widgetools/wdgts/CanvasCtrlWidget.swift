//
//  CanvasCtrl.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/13.
//

import WidgetKit
import SwiftUI
import Intents

struct CanvasCtrlProvider: IntentTimelineProvider {
    typealias Entry = CanvasCtrlEntry
    typealias Intent = CanvasConfigIntent
    
    func placeholder(in context: Context) -> CanvasCtrlEntry {
        CanvasCtrlEntry(date: Date(), configuration: Intent())
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (CanvasCtrlEntry) -> ()) {
        let entry = CanvasCtrlEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [
            CanvasCtrlEntry(date: Date(), configuration: configuration)
        ], policy: .never)
        completion(timeline)
    }
}

struct CanvasCtrlEntry: TimelineEntry {
    let date: Date
    let configuration: CanvasCtrlProvider.Intent
}

struct WGCanvasCtrlView: View {
    var canvasID: String
    var selectedColor: Int
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
        self.selectedColor = ud.integer(forKey: "_canvas_\(canvasID)_cfg")
        self.pos = pos
    }
    
    let staticColors: [Color] = [Color(UIColor.systemGray5), .blue, .red, .green]
    
    var body: some View {
        ZStack {
            if let wallpaperClip = background {
                Image(uiImage: wallpaperClip).resizable()
            }
            GeometryReader {geo in
                let w = geo.size.width / 8
                HStack(spacing: 10) {
                    Link(destination: URL(string: "canvasctrl/\(canvasID)/clear")!) {
                        Circle().fill().foregroundColor(.gray)
                            .frame(width: w, height: w)
                            .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 3)
                            .overlay(
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.white)
                                    .frame(width: w / 2, height: w / 2)
                            ).offset(y: -2)
                    }.frame(width: w, height: w)
                    ForEach(0...3, id: \.self) {index in
                        Link(destination: URL(string: "canvasctrl/\(canvasID)/\(index - 1)")!) {
                            Circle().fill().foregroundColor(staticColors[index])
                                .frame(width: w, height: w)
                                .shadow(color: Color(UIColor(white: 0, alpha: selectedColor == index - 1 ? 0 : 0.5)), radius: 2, y: 2)
                                .overlay(
                                    Circle().fill().foregroundColor(.white)
                                        .frame(width: w / 2, height: w / 2)
                                        .opacity(selectedColor == index - 1 ? 1 : 0)
                                )
                                .offset(y: selectedColor == index - 1 ? 0 : -2)
                        }.frame(width: w, height: w)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 80)
            .background(
                Capsule(style: .continuous).fill().foregroundColor(Color(UIColor.systemBackground))
                    .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 4)
            )
            .widgetURL(URL(string: "return/0")!)
        }
    }
}

struct WTCanvasControl: Widget {
    let kind: String = "com.wyw.widgetools.widget.canvasctrl"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CanvasCtrlProvider.Intent.self,
            provider: CanvasCtrlProvider()
        ) {entry in WGCanvasCtrlView(
            canvasID: hashSHA256(entry.configuration.uniqueTitle ?? "default"),
            pos: entry.configuration.transparent == 1 ? entry.configuration.position : nil
        )}
        .configurationDisplayName(localized("canvasctrl_name"))
        .description(localized("canvasctrl_desc"))
        .supportedFamilies([.systemMedium])
    }
}

struct CanvasCtrl_Previews: PreviewProvider {
    static var previews: some View {
        WGCanvasCtrlView(
            canvasID: hashSHA256("default"), pos: nil
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
