//
//  RandgenWidget.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/12.
//

import WidgetKit
import SwiftUI
import Intents

struct RandgenProvider: IntentTimelineProvider {
    typealias Entry = RandgenEntry
    typealias Intent = RandomConfigIntent
    
    func placeholder(in context: Context) -> RandgenEntry {
        RandgenEntry(date: Date(), configuration: Intent(), number: 12345678)
    }
    
    func generateRandom(_ config: Intent) -> Int? {
        if let configMin = config.min?.intValue, let configMax = config.max?.intValue {
            let range = configMax - configMin
            if range == 0 {
                return configMax
            } else if range > 0 {
                return Int(arc4random()) % range + configMin
            } else {
                return nil
            }
        }
        return 0
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (RandgenEntry) -> ()) {
        //let result = generateRandom(configuration)
        let entry = RandgenEntry(date: Date(), configuration: configuration, number: 1)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let result = generateRandom(configuration)
        completion(Timeline(entries: [
            RandgenEntry(date: Date(), configuration: configuration, number: result)
        ], policy: .never))
    }
}

struct RandgenEntry: TimelineEntry {
    let date: Date
    let configuration: RandgenProvider.Intent
    let number: Int?
}

struct WGRandgenView: View {
    var entry: RandgenProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        RandgenView(
            isSmallWidget: widgetFamily == .systemSmall,
            number: entry.number
        )
    }
}

struct WTRandgen: Widget {
    let kind: String = "com.wyw.widgetools.widget.randgen"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: RandgenProvider.Intent.self,
            provider: RandgenProvider()
        ) {entry in WGRandgenView(entry: entry)}
        .configurationDisplayName(localized("randgen_name"))
        .description(localized("randgen_desc"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Randgen_Previews: PreviewProvider {
    static var previews: some View {
        WGRandgenView(
            entry: RandgenEntry(date: Date(), configuration: RandgenProvider.Intent(), number: 12345678)
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
