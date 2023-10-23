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
    var number: Int?
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
    
    init(number: Int?, pos: HomeScreenPosition?) {
        self.number = number
        self.pos = pos
    }
    
    @ViewBuilder var buttonLabel: some View {
        Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .background(
                Circle().fill().foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(UIColor(white: 0, alpha: 0.5)), radius: 2, y: 2)
            ).frame(width: 60, height: 60)
    }
    
    var body: some View {
        ZStack {
            if let wallpaperClip = background {
                Image(uiImage: wallpaperClip).resizable()
            }
            if widgetFamily == .systemSmall {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        if let result = number {
                            Text("\(result)")
                                .font(.system(size: 30, weight: .semibold))
                                .contentTransition(.numericText())
                                .minimumScaleFactor(0.5)
                                .padding(background == nil ? 4 : 10)
                        } else {
                            Text("Config error").padding()
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Text("Tap to\nrefresh")
                            .font(.system(size: 14, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Spacer()
                }
                .background(
                    Circle().fill().foregroundColor(Color(UIColor.systemBackground))
                        .padding(6)
                        .shadow(color: Color(UIColor(
                            white: 0, alpha: background == nil ? 0.0 : 0.5
                        )), radius: 2, y: 4)
                )
                .widgetURL(URL(string: "randgen/new")!)
                if #available(iOS 17, *) {
                    Button(intent: ButtonIntent("randgen/new")) {
                        Circle().fill().foregroundColor(Color(UIColor(white: 1, alpha: 0.000001)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.buttonStyle(WTLBtnStyle())
                }
            } else { // med and large
                HStack {
                    Spacer()
                    if let result = number {
                        Text("\(result)")
                            .font(.system(size: 32, weight: .semibold))
                            .contentTransition(.numericText())
                    } else {
                        Text("Config error")
                            .font(.system(size: 32, weight: .semibold))
                    }
                    Spacer()
                    if #available(iOS 17, *) {
                        Button(intent: ButtonIntent("randgen/new")) {
                            buttonLabel
                        }.buttonStyle(WTLBtnStyle()).padding(.trailing)
                    } else {
                        Link(destination: URL(string: "randgen/new")!) {
                            buttonLabel
                        }.padding(.trailing)
                    }
                }
                .padding(.vertical)
                .background(
                    Capsule(style: .continuous).fill().foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(UIColor(
                            white: 0, alpha: background == nil ? 0.0 : 0.5
                        )), radius: 2, y: 4)
                )
            }
        }
    }
}

struct WTRandgen: Widget {
    let kind: String = "com.wyw.widgetools.widget.randgen"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind, intent: RandgenProvider.Intent.self,
            provider: RandgenProvider()
        ) {entry in WGRandgenView(
            number: entry.number,
            pos: entry.configuration.transparent == 1 ? entry.configuration.position : nil
        )}
        .configurationDisplayName(localized("randgen_name"))
        .description(localized("randgen_desc"))
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

@available (iOS 17.0, *)
struct Randgen_Previews: PreviewProvider {
    static var previews: some View {
        WGRandgenView(
            number: 12345678, pos: nil
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
        .containerBackground(for: .widget) {Spacer()}
    }
}
