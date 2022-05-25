//
//  TimerWidget.swift
//  wdgtsExtension
//
//  Created by wyw on 2022/5/15.
//

import WidgetKit
import SwiftUI
import Intents

struct TimerProvider: IntentTimelineProvider {
    typealias Entry = TimerEntry
    typealias Intent = TimerConfigIntent
    
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), configuration: Intent(), showBadge: nil)
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (TimerEntry) -> ()) {
        let entry = TimerEntry(date: Date(), configuration: configuration, showBadge: nil)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
        
        let op = ud.integer(forKey: "_timer_\(hashSHA256(configuration.uniqueTitle ?? "shared"))_op")
        let operationBadge = op > 0 ? "+1" : (op < 0 ? "-1" : nil)
        
        let timeline = Timeline(entries: [
            TimerEntry(date: currentDate, configuration: configuration, showBadge: operationBadge),
            TimerEntry(date: nextDate, configuration: configuration, showBadge: nil)
        ], policy: .never)
        completion(timeline)
    }
}

struct TimerEntry: TimelineEntry {
    let date: Date
    let configuration: TimerProvider.Intent
    let countdownSec: Int
}

struct WGTimerView: View {
    var countdown: Int
    var title: String
    var timerID: String
    
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
        self.timerID = hashSHA256(title)
        self.timer = ud.integer(forKey: "_timer_\(self.timerID)")
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
                    Spacer()
                    VStack {
                        Header()
                        HStack {
                            Text("\(Timer)")
                                .font(.system(size: 40, weight: .regular, design: .monospaced))
                            if let badge = showBadge {
                                Text(badge).foregroundColor(.blue)
                            }
                        }
                    }.padding(.horizontal)
                    Spacer()
                    BtnInc()
                }
                .padding()
                .background(
                    Capsule().fill().foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 4)
                )
            } else {
                VStack {
                    Header()
                    HStack {
                        Text("\(Timer)")
                            .font(.system(size: 80, weight: .regular, design: .monospaced))
                            .padding()
                        if let badge = showBadge {
                            Text(badge).foregroundColor(.blue)
                        }
                    }
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
        }.widgetURL(URL(string: "return/0")!)
    }
    
    @ViewBuilder func Header() -> some View {
        ZStack {
            Text("\(title)")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder func BtnDec() -> some View {
        Link(destination: URL(string: "Timer/\(timerID)/dec")!) {
            Image(systemName: "minus")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .background(
                    Circle().fill().foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
                )
        }.frame(width: 60, height: 60)
    }
    
    @ViewBuilder func BtnInc() -> some View {
        Link(destination: URL(string: "Timer/\(timerID)/inc")!) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .background(
                    Circle().fill().foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
                )
        }.frame(width: 60, height: 60)
    }
}

struct WTTimer: Widget {
    let kind: String = "com.wyw.widgetools.widget.timer"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: TimerProvider.Intent.self,
            provider: TimerProvider()
        ) {entry in WGTimerView(
            title: entry.configuration.uniqueTitle ?? "Sample",
            showBadge: entry.showBadge,
            pos: entry.configuration.transparent == 1 ? entry.configuration.position : nil
        )}
        .configurationDisplayName(localized("timer_name"))
        .description(localized("timer_desc"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct Timer_Previews: PreviewProvider {
    static var previews: some View {
        WGTimerView(
            title: "Sample", showBadge: "bdg", pos: nil
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
