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
        
        let op = ud.integer(forKey: "_counter_\(hashSHA256(configuration.uniqueTitle ?? "shared"))_op")
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

struct WGCounterView: View {
    var counter: Int
    var title: String
    var counterID: String
    var showBadge: String?
    
    init(title: String, showBadge: String?) {
        self.showBadge = showBadge
        self.title = title
        self.counterID = hashSHA256(title)
        self.counter = ud.integer(forKey: "_counter_\(self.counterID)")
        
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(title)")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.gray)
                if let badge = showBadge {
                    Text(badge).foregroundColor(.blue)
                }
            }
            
            HStack {
                Link(destination: URL(string: "counter/\(counterID)/dec")!) {
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
                Link(destination: URL(string: "counter/\(counterID)/inc")!) {
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

struct WTCounter: Widget {
    let kind: String = "com.wyw.widgetools.widget.counter"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CounterProvider.Intent.self,
            provider: CounterProvider()
        ) {entry in WGCounterView(
            title: entry.configuration.uniqueTitle ?? "Sample", showBadge: entry.showBadge
        )}
        .configurationDisplayName(localized("counter_name"))
        .description(localized("counter_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct Counter_Previews: PreviewProvider {
    static var previews: some View {
        WGCounterView(
            title: "Sample", showBadge: "bdg"
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
