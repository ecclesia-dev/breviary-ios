import Foundation

/// Liturgical rank/class under 1962 rubrics
enum LiturgicalRank: Int, Comparable {
    case firstClass = 1
    case secondClass = 2
    case thirdClass = 3
    case fourthClass = 4
    case feria = 5

    static func < (lhs: LiturgicalRank, rhs: LiturgicalRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .firstClass: "I Class"
        case .secondClass: "II Class"
        case .thirdClass: "III Class"
        case .fourthClass: "IV Class"
        case .feria: "Feria"
        }
    }
}

enum LiturgicalSeason: String {
    case advent = "Advent"
    case christmas = "Christmas"
    case epiphany = "Epiphany"
    case septuagesima = "Septuagesima"
    case lent = "Lent"
    case passiontide = "Passiontide"
    case easter = "Easter"
    case pentecost = "Pentecost"

    var liturgicalColor: LiturgicalColor {
        switch self {
        case .advent, .lent, .septuagesima, .passiontide: .purple
        case .christmas, .easter: .white
        case .epiphany, .pentecost: .green
        }
    }
}

enum LiturgicalColor: String {
    case white = "White"
    case red = "Red"
    case green = "Green"
    case purple = "Purple"
    case black = "Black"
    case rose = "Rose"
}

/// Represents a single liturgical day with its office assignments
struct LiturgicalDay: Identifiable {
    let id = UUID()
    let date: Date
    let name: String
    let season: LiturgicalSeason
    let rank: LiturgicalRank
    let color: LiturgicalColor
    let sanctiFile: String?
    let temporaFile: String?
    let communeFile: String?

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
}
