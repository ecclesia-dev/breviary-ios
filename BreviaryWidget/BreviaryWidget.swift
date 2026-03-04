import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct BreviaryEntry: TimelineEntry {
    let date: Date
    let hourName: String
    let hourLatinName: String
    let openingVersicle: String
    let feastName: String
    let systemImage: String
}

// MARK: - Timeline Provider

struct BreviaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> BreviaryEntry {
        BreviaryEntry(
            date: .now,
            hourName: "Vespers",
            hourLatinName: "Ad Vesperas",
            openingVersicle: "Deus, in adjutorium meum intende.",
            feastName: "Sunday in Pentecost",
            systemImage: "sunset"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BreviaryEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BreviaryEntry>) -> Void) {
        var entries: [BreviaryEntry] = []
        let now = Date()

        // Create entries for each hour transition today
        for hour in CanonicalHour.allCases {
            let range = hour.timeRange
            var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
            components.hour = range.start
            components.minute = 0
            if let entryDate = Calendar.current.date(from: components), entryDate >= now {
                entries.append(makeEntry(for: entryDate))
            }
        }

        if entries.isEmpty {
            entries.append(makeEntry(for: now))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func makeEntry(for date: Date) -> BreviaryEntry {
        let hour = CanonicalHour.current(at: date)
        let day = LiturgicalCalendar.resolve(date: date)

        let versicle = hour.openingVersicle
            .components(separatedBy: "\n")
            .first ?? hour.openingVersicle

        return BreviaryEntry(
            date: date,
            hourName: hour.name,
            hourLatinName: hour.latinName,
            openingVersicle: versicle,
            feastName: day.name,
            systemImage: hour.systemImage
        )
    }
}

// MARK: - Widget View

struct BreviaryWidgetEntryView: View {
    var entry: BreviaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entry.systemImage)
                    .font(.caption)
                Text(entry.hourName)
                    .font(.caption.bold())
            }
            .foregroundStyle(.yellow)

            Text(entry.hourLatinName)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            Text(entry.openingVersicle)
                .font(.caption2)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(entry.feastName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .containerBackground(for: .widget) {
            Color(red: 0.06, green: 0.05, blue: 0.09)
        }
    }
}

// MARK: - Widget Configuration

struct BreviaryWidget: Widget {
    let kind: String = "BreviaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BreviaryProvider()) { entry in
            BreviaryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Divine Office")
        .description("Shows the current canonical hour and its opening prayer.")
        .supportedFamilies([.systemSmall])
    }
}
