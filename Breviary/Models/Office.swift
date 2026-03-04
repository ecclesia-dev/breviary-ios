import Foundation

/// A complete office for one canonical hour on a given day
struct Office: Identifiable {
    let id = UUID()
    let hour: CanonicalHour
    let day: LiturgicalDay
    let sections: [OfficeSection]

    var openingVersicle: String {
        hour.openingVersicle
    }

    var collect: OfficeSection? {
        sections.last { $0.type == .collect }
    }

    var hymn: OfficeSection? {
        sections.first { $0.type == .hymn }
    }
}
