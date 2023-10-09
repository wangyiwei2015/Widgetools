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
    
    init(title: String, showBadge: String?, pos: HomeScreenPosition?) {
        self.showBadge = showBadge
        self.title = title
        self.counterID = hashSHA256(title)
        self.counter = ud.integer(forKey: "_counter_\(self.counterID)")
        self.pos = pos
    }
    
    var body: some View {
        ZStack {
            if let wallpaperClip = background {
                Image(uiImage: wallpaperClip).resizable()
            }
            if widgetFamily == .systemMedium {
                HStack {
                    BtnDec()
                    VStack {
                        Header()
                        Text("\(counter)")
                            .font(.system(size: 40, weight: .regular, design: .monospaced))
                    }.padding(.horizontal)
                    BtnInc()
                }
                .padding()
                .background(
                    Capsule(style: .continuous).fill().foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 4)
                )
            } else {
                VStack {
                    Header()
                    Text("\(counter)")
                        .font(.system(size: 80, weight: .regular, design: .monospaced))
                        .padding()
                    HStack {
                        BtnDec().padding(.horizontal)
                        BtnInc().padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    Color(UIColor.systemBackground)
                        .mask(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 4)
                )
            }
        }
    }
    
    @ViewBuilder func Header() -> some View {
        HStack {
            Text("\(title)")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.gray)
            if let badge = showBadge {
                Text(badge).foregroundColor(.blue)
            }
        }
    }
    
    @ViewBuilder func buttonLabel(_ isInc: Bool) -> some View {
        Image(systemName: isInc ? "plus" : "minus")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .background(
                Circle().fill().foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
            ).frame(width: 60, height: 60)
    }
    
    @ViewBuilder func BtnDec() -> some View {
        if #available(iOS 17, *) {
            Button(intent: ButtonIntent("counter/\(counterID)/dec")) {
                buttonLabel(false)
            }.frame(width: 60, height: 60)
        } else {
            Link(destination: URL(string: "counter/\(counterID)/dec")!) {
                buttonLabel(false)
            }.frame(width: 60, height: 60)
        }
    }
    
    @ViewBuilder func BtnInc() -> some View {
        if #available(iOS 17, *) {
            Button(intent: ButtonIntent("counter/\(counterID)/inc")) {
                buttonLabel(true)
            }.frame(width: 60, height: 60)
        } else {
            Link(destination: URL(string: "counter/\(counterID)/inc")!) {
                buttonLabel(true)
            }.frame(width: 60, height: 60)
        }
    }
}

struct WTCounter: Widget {
    let kind: String = "com.wyw.widgetools.widget.counter"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: CounterProvider.Intent.self,
            provider: CounterProvider()
        ) {entry in WGCounterView(
            title: entry.configuration.uniqueTitle ?? "Sample",
            showBadge: entry.showBadge,
            pos: entry.configuration.transparent == 1 ? entry.configuration.position : nil
        )}
        .configurationDisplayName(localized("counter_name"))
        .description(localized("counter_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

struct Counter_Previews: PreviewProvider {
    static var previews: some View {
        WGCounterView(
            title: "Sample", showBadge: "bdg", pos: nil
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
