import Foundation

/// The eight canonical hours of the Traditional Roman Breviary
enum CanonicalHour: Int, CaseIterable, Identifiable, Codable {
    case matins = 0
    case lauds
    case prime
    case terce
    case sext
    case none
    case vespers
    case compline

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .matins: "Matins"
        case .lauds: "Lauds"
        case .prime: "Prime"
        case .terce: "Terce"
        case .sext: "Sext"
        case .none: "None"
        case .vespers: "Vespers"
        case .compline: "Compline"
        }
    }

    var latinName: String {
        switch self {
        case .matins: "Ad Matutinum"
        case .lauds: "Ad Laudes"
        case .prime: "Ad Primam"
        case .terce: "Ad Tertiam"
        case .sext: "Ad Sextam"
        case .none: "Ad Nonam"
        case .vespers: "Ad Vesperas"
        case .compline: "Ad Completorium"
        }
    }

    var systemImage: String {
        switch self {
        case .matins: "moon.stars"
        case .lauds: "sunrise"
        case .prime: "sun.and.horizon"
        case .terce: "sun.min"
        case .sext: "sun.max"
        case .none: "sun.haze"
        case .vespers: "sunset"
        case .compline: "moon"
        }
    }

    var openingVersicle: String {
        switch self {
        case .matins:
            "V. Domine, labia mea aperies.\nR. Et os meum annuntiabit laudem tuam."
        case .compline:
            "V. Jube, Domine, benedicere.\nBenedictio. Noctem quietam et finem perfectum concedat nobis Dominus omnipotens. R. Amen."
        default:
            "V. Deus, in adjutorium meum intende.\nR. Domine, ad adjuvandum me festina."
        }
    }

    /// Traditional time range for this hour (start hour, end hour inclusive)
    var timeRange: (start: Int, end: Int) {
        switch self {
        case .matins: (0, 2)
        case .lauds: (3, 5)
        case .prime: (6, 8)
        case .terce: (9, 11)
        case .sext: (12, 13)
        case .none: (14, 15)
        case .vespers: (16, 18)
        case .compline: (19, 23)
        }
    }

    /// Returns the canonical hour for the current time of day
    static func current(at date: Date = .now) -> CanonicalHour {
        let hour = Calendar.current.component(.hour, from: date)
        return CanonicalHour.allCases.first { h in
            let range = h.timeRange
            return hour >= range.start && hour <= range.end
        } ?? .compline
    }
}
