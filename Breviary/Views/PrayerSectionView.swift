import SwiftUI

struct PrayerSectionView: View {
    let section: OfficeSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(section.title, systemImage: iconForType(section.type))
                .font(.caption.bold())
                .foregroundStyle(colorForType(section.type))

            if let rubric = section.rubric {
                Text(rubric)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(BreviaryTheme.burgundy)
            }

            Text(section.content)
                .font(fontForType(section.type))
                .foregroundStyle(BreviaryTheme.cream)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(backgroundForType(section.type), in: .rect(cornerRadius: 12))
    }

    private func iconForType(_ type: OfficeSectionType) -> String {
        switch type {
        case .invitatory: "sparkles"
        case .hymn: "music.note"
        case .antiphon: "quote.opening"
        case .psalm: "book.closed"
        case .chapter: "text.book.closed"
        case .responsory, .responsoryBreve: "arrow.triangle.2.circlepath"
        case .versicle: "arrow.right.arrow.left"
        case .canticle: "music.note.list"
        case .reading: "book.pages"
        case .collect: "hands.sparkles"
        case .commemoration: "bookmark"
        case .rubric: "hand.point.right"
        case .doxology: "crown"
        case .preces: "person.2"
        case .benediction: "cross"
        }
    }

    private func colorForType(_ type: OfficeSectionType) -> Color {
        switch type {
        case .rubric: BreviaryTheme.burgundy
        case .collect: BreviaryTheme.gold
        case .hymn, .canticle: BreviaryTheme.gold.opacity(0.8)
        default: BreviaryTheme.muted
        }
    }

    private func fontForType(_ type: OfficeSectionType) -> Font {
        switch type {
        case .rubric: .caption.italic()
        default: .body
        }
    }

    private func backgroundForType(_ type: OfficeSectionType) -> Color {
        switch type {
        case .rubric: .clear
        case .collect: BreviaryTheme.gold.opacity(0.08)
        case .hymn, .canticle: BreviaryTheme.cardBg.opacity(0.8)
        default: BreviaryTheme.cardBg
        }
    }
}
