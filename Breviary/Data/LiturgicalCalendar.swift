import Foundation

/// Computes the liturgical calendar for the Traditional Roman Rite (1962 rubrics)
struct LiturgicalCalendar {

    // MARK: - Easter Computation (Anonymous Gregorian Algorithm)

    static func easter(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }

    // MARK: - Key Moveable Dates

    struct KeyDates {
        let easter: Date
        let ashWednesday: Date
        let septuagesima: Date
        let palmSunday: Date
        let ascension: Date
        let pentecost: Date
        let corpusChristi: Date
        let adventStart: Date
    }

    static func keyDates(year: Int) -> KeyDates {
        let cal = Calendar.current
        let easterDate = easter(year: year)

        return KeyDates(
            easter: easterDate,
            ashWednesday: cal.date(byAdding: .day, value: -46, to: easterDate)!,
            septuagesima: cal.date(byAdding: .day, value: -63, to: easterDate)!,
            palmSunday: cal.date(byAdding: .day, value: -7, to: easterDate)!,
            ascension: cal.date(byAdding: .day, value: 39, to: easterDate)!,
            pentecost: cal.date(byAdding: .day, value: 49, to: easterDate)!,
            corpusChristi: cal.date(byAdding: .day, value: 60, to: easterDate)!,
            adventStart: adventStart(year: year)
        )
    }

    /// First Sunday of Advent (nearest Sunday to Nov 30)
    static func adventStart(year: Int) -> Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = 11
        components.day = 30
        let stAndrew = cal.date(from: components)!
        let weekday = cal.component(.weekday, from: stAndrew)

        if weekday == 1 { return stAndrew }
        let daysToSunday = weekday <= 4 ? -(weekday - 1) : (8 - weekday)
        return cal.date(byAdding: .day, value: daysToSunday, to: stAndrew)!
    }

    // MARK: - Resolve Liturgical Day

    static func resolve(date: Date) -> LiturgicalDay {
        let cal = Calendar.current
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        let keys = keyDates(year: year)

        let season = determineSeason(date: date, keys: keys, cal: cal)
        let sanctiFile = String(format: "%02d-%02d", month, day)
        let temporaFile = determineTemporaFile(date: date, keys: keys, cal: cal, season: season)

        // Check known major feasts
        if let sancti = majorFeasts[sanctiFile] {
            return LiturgicalDay(
                date: date, name: sancti.name, season: season,
                rank: sancti.rank, color: sancti.color,
                sanctiFile: sanctiFile, temporaFile: temporaFile, communeFile: nil
            )
        }

        // Default: temporal cycle feria
        let name = temporalName(date: date, season: season, cal: cal)
        return LiturgicalDay(
            date: date, name: name, season: season,
            rank: .feria, color: season.liturgicalColor,
            sanctiFile: sanctiFile, temporaFile: temporaFile, communeFile: nil
        )
    }

    // MARK: - Season Determination

    private static func determineSeason(date: Date, keys: KeyDates, cal: Calendar) -> LiturgicalSeason {
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)

        // Advent
        let advent = keys.adventStart
        if date >= advent {
            if month == 12 && day >= 25 { return .christmas }
            return .advent
        }

        // Christmas octave (Dec 25 - Jan 5)
        if (month == 12 && day >= 25) || (month == 1 && day <= 5) {
            return .christmas
        }

        // Epiphany until Septuagesima
        if month == 1 && day >= 6 && date < keys.septuagesima {
            return .epiphany
        }
        if date < keys.septuagesima {
            return .epiphany
        }

        // Septuagesima
        if date >= keys.septuagesima && date < keys.ashWednesday {
            return .septuagesima
        }

        // Lent
        let passionSunday = cal.date(byAdding: .day, value: -14, to: keys.easter)!
        if date >= keys.ashWednesday && date < passionSunday {
            return .lent
        }

        // Passiontide
        if date >= passionSunday && date < keys.easter {
            return .passiontide
        }

        // Easter (includes Pentecost Sunday itself — Pasc7-0)
        if date >= keys.easter && date <= keys.pentecost {
            return .easter
        }

        // Time after Pentecost until next Advent
        let nextAdvent = adventStart(year: year)
        if date >= keys.pentecost && date < nextAdvent {
            return .pentecost
        }

        return .pentecost
    }

    // MARK: - Tempora File Mapping

    private static func determineTemporaFile(
        date: Date, keys: KeyDates, cal: Calendar, season: LiturgicalSeason
    ) -> String? {
        let weekday = cal.component(.weekday, from: date) - 1 // 0 = Sunday

        switch season {
        case .advent:
            let weeks = cal.dateComponents([.weekOfYear], from: keys.adventStart, to: date).weekOfYear ?? 0
            return "Adv\(min(weeks + 1, 4))-\(weekday)"
        case .christmas:
            return "Nat1-\(weekday)"
        case .epiphany:
            let jan6 = cal.date(from: DateComponents(year: cal.component(.year, from: date), month: 1, day: 6))!
            let weeks = cal.dateComponents([.weekOfYear], from: jan6, to: date).weekOfYear ?? 0
            return "Epi\(min(weeks + 1, 6))-\(weekday)"
        case .septuagesima:
            let weeks = cal.dateComponents([.weekOfYear], from: keys.septuagesima, to: date).weekOfYear ?? 0
            return "Quadp\(weeks + 1)-\(weekday)"
        case .lent:
            // Ash Wednesday through Saturday before Lent I Sunday → Quadp3-X series.
            // Lent I Sunday onward → Quad1-X, Quad2-X, … counted from the first Sunday of Lent.
            // Ash Wednesday is always a Wednesday; the first Sunday of Lent is 4 days later.
            let firstSundayOfLent = cal.date(byAdding: .day, value: 4, to: keys.ashWednesday)!
            if date < firstSundayOfLent {
                return "Quadp3-\(weekday)"
            }
            let weeks = cal.dateComponents([.weekOfYear], from: firstSundayOfLent, to: date).weekOfYear ?? 0
            return "Quad\(weeks + 1)-\(weekday)"
        case .passiontide:
            // Passion Sunday week = Quad5-X, Holy Week = Quad6-X.
            let passionSunday = cal.date(byAdding: .day, value: -14, to: keys.easter)!
            let weeks = cal.dateComponents([.weekOfYear], from: passionSunday, to: date).weekOfYear ?? 0
            return "Quad\(weeks + 5)-\(weekday)"
        case .easter:
            // Pentecost Sunday stays in .easter → Pasc7-0.
            let weeks = cal.dateComponents([.weekOfYear], from: keys.easter, to: date).weekOfYear ?? 0
            return "Pasc\(weeks)-\(weekday)"
        case .pentecost:
            // Count from the day after Pentecost so that Trinity Sunday (Pent+7 days)
            // correctly maps to Pent01-0 rather than Pent02-0.
            let dayAfterPentecost = cal.date(byAdding: .day, value: 1, to: keys.pentecost)!
            let weeks = cal.dateComponents([.weekOfYear], from: dayAfterPentecost, to: date).weekOfYear ?? 0
            return "Pent\(String(format: "%02d", weeks + 1))-\(weekday)"
        }
    }

    // MARK: - Temporal Name

    private static func temporalName(date: Date, season: LiturgicalSeason, cal: Calendar) -> String {
        let weekday = cal.component(.weekday, from: date)
        let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        if weekday == 1 {
            return "\(season.rawValue) Sunday"
        }
        return "\(dayNames[weekday]) in \(season.rawValue)"
    }

    // MARK: - Major Feasts (Hardcoded for MVP)

    private struct FeastInfo {
        let name: String
        let rank: LiturgicalRank
        let color: LiturgicalColor
    }

    private static let majorFeasts: [String: FeastInfo] = [
        "01-01": FeastInfo(name: "Circumcision of Our Lord", rank: .secondClass, color: .white),
        "01-06": FeastInfo(name: "Epiphany of Our Lord", rank: .firstClass, color: .white),
        "02-02": FeastInfo(name: "Purification of the B.V.M.", rank: .secondClass, color: .white),
        "03-19": FeastInfo(name: "St. Joseph, Spouse of the B.V.M.", rank: .firstClass, color: .white),
        "03-25": FeastInfo(name: "Annunciation of the B.V.M.", rank: .firstClass, color: .white),
        "05-01": FeastInfo(name: "St. Joseph the Worker", rank: .firstClass, color: .white),
        "06-24": FeastInfo(name: "Nativity of St. John the Baptist", rank: .firstClass, color: .white),
        "06-29": FeastInfo(name: "Ss. Peter and Paul, Apostles", rank: .firstClass, color: .red),
        "08-06": FeastInfo(name: "Transfiguration of Our Lord", rank: .secondClass, color: .white),
        "08-15": FeastInfo(name: "Assumption of the B.V.M.", rank: .firstClass, color: .white),
        "09-08": FeastInfo(name: "Nativity of the B.V.M.", rank: .secondClass, color: .white),
        "09-29": FeastInfo(name: "Dedication of St. Michael the Archangel", rank: .firstClass, color: .white),
        "10-07": FeastInfo(name: "Our Lady of the Rosary", rank: .secondClass, color: .white),
        "11-01": FeastInfo(name: "All Saints", rank: .firstClass, color: .white),
        "11-02": FeastInfo(name: "All Souls", rank: .firstClass, color: .black),
        "12-08": FeastInfo(name: "Immaculate Conception of the B.V.M.", rank: .firstClass, color: .white),
        "12-25": FeastInfo(name: "Nativity of Our Lord Jesus Christ", rank: .firstClass, color: .white),
    ]
}
