//
//  DooldaWidget.swift
//  DooldaWidget
//
//  Created by Seunghun Yang on 2021/11/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), count: 5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), count: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, count: 9)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct EmojiWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry

    var body: some View {
        VStack{
            ZStack {
                VStack {
                    Spacer(minLength: 80)
                    HStack {
                        Spacer(minLength: 80)
                        Image("hedgehogWriting")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                VStack {
                    Spacer()
                    Text("둘이 함께 쓴")
                        .font(Font.custom("dovemayo", size: 24))
                        .foregroundColor(colorScheme == .dark ?  Color("dooldaLabelDark") : Color("dooldaLabelLight"))
                    Spacer(minLength: 120)
                }
                VStack {
                    Spacer(minLength: 30)
                    HStack {
                        Spacer(minLength: 30)
                        Text("\(entry.count)장")
                            .font(Font.custom("dovemayo", size: 36))
                            .foregroundColor(colorScheme == .dark ?  Color("dooldaLabelDark") : Color("dooldaLabelLight"))
                        Spacer(minLength: 60)
                    }
                    Spacer(minLength: 72)
                }
            }
        }
        .foregroundColor(colorScheme == .dark ?  Color("dooldaBackgroundDark") : Color("dooldaBackgroundLight"))
    }
}

@main
struct EmojiWidget: Widget {
    let kind: String = "둘다 위젯"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EmojiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("우리 둘만의 다이어리")
        .description("우리가 함께한 페이지들")
    }
}

struct EmojiWidget_Previews: PreviewProvider {
    static var previews: some View {
        EmojiWidgetEntryView(entry: SimpleEntry(date: Date(), count: 3))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
