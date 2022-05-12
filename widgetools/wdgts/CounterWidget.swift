//
//  wdgts.swift
//  wdgts
//
//  Created by wyw on 2022/5/12.
//

import WidgetKit
import SwiftUI
import Intents

struct CounterProvider: IntentTimelineProvider {
    typealias Entry = CounterEntry
    typealias Intent = CounterConfigIntent
    
    func placeholder(in context: Context) -> CounterEntry {
        CounterEntry(date: Date(), configuration: Intent(), showBadge: nil)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (CounterEntry) -> ()) {
        let entry = CounterEntry(date: Date(), configuration: configuration, showBadge: nil)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
        
        let op = ud.integer(forKey: "\(configuration.uniqueTitle ?? "shared")_op")
        let operationBadge = op > 0 ? "+1" : (op < 0 ? "-1" : nil)
        
        let timeline = Timeline(entries: [
            CounterEntry(date: currentDate, configuration: configuration, showBadge: operationBadge),
            CounterEntry(date: nextDate, configuration: configuration, showBadge: nil)
        ], policy: .never)
        completion(timeline)
    }
}

struct CounterEntry: TimelineEntry {
    let date: Date
    let configuration: CounterProvider.Intent
    let showBadge: String?
}

struct WTWGextView: View {
    var entry: CounterProvider.Entry
    
    var body: some View {
        CounterView(
            dataID: entry.configuration.uniqueTitle ?? "shared",
            showBadge: entry.showBadge
        )
    }
}

struct WTCounter: Widget {
    let kind: String = "com.wyw.widgetools.widget.counter"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CounterProvider.Intent.self,
            provider: CounterProvider()
        ) {entry in WTWGextView(entry: entry)}
        .configurationDisplayName(localized("counter_name"))
        .description(localized("counter_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct wdgts_Previews: PreviewProvider {
    static var previews: some View {
        WTWGextView(
            entry: CounterEntry(date: Date(), configuration: CounterProvider.Intent(), showBadge: "bdg")
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
