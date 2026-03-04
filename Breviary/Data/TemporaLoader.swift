import Foundation

/// Loads and parses the temporal/sanctoral data for a given liturgical day.
/// Priority: Sancti file (if feast), then Tempora file.
struct TemporaLoader {

    let day: LiturgicalDay
    private let sections: [OfficeDataParser.RawSection]

    init(day: LiturgicalDay) {
        self.day = day
        var loaded: [OfficeDataParser.RawSection] = []

        // Try Sancti (feast day) first
        if let sanctiFile = day.sanctiFile {
            loaded = DataBundle.parse("Sancti/\(sanctiFile).txt")
        }

        // Fall back to Tempora
        if loaded.isEmpty, let temporaFile = day.temporaFile {
            loaded = DataBundle.parse("Tempora/\(temporaFile).txt")
        }

        // Last resort — try some common fallbacks
        if loaded.isEmpty {
            loaded = DataBundle.parse("Tempora/Pent01-0.txt")
        }

        self.sections = loaded
    }

    // MARK: - Accessors

    var officiumName: String? { section("Officium") }

    var collect: String? {
        guard let raw = section("Oratio") else { return nil }
        return OfficeDataParser.expandVariable(raw)
    }

    /// Antiphon for Matins / Invitatory area
    var antiphon1: String? { section("Ant 1") ?? section("Ant 1_") }

    /// Multiple antiphons for Lauds (one per line in [Ant Laudes])
    var antiphonLaudes: [String] {
        guard let raw = section("Ant Laudes") else { return [] }
        return raw.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    /// Magnificat antiphon for Vespers
    var antiphon2: String? { section("Ant 2") ?? section("Ant 2_") }

    /// Chapter (capitulum) for Lauds
    var capitulumLaudes: String? {
        guard let raw = section("Capitulum Laudes") else { return nil }
        return OfficeDataParser.expandVariable(raw)
    }

    /// Chapter (capitulum) for None (also used for Little Hours)
    var capitulumNona: String? {
        guard let raw = section("Capitulum Nona") else { return nil }
        return OfficeDataParser.expandVariable(raw)
    }

    // MARK: - Matins Readings and Responsories (Nocturns)

    func reading(_ n: Int) -> String? {
        guard let raw = section("Lectio\(n)") else { return nil }
        return formatReading(raw)
    }

    func responsory(_ n: Int) -> String? {
        section("Responsory\(n)")
    }

    // MARK: - Helpers

    private func section(_ name: String) -> String? {
        OfficeDataParser.section(named: name, in: sections)
    }

    private func formatReading(_ raw: String) -> String {
        // Format: may start with "Lesson from..." or "!Ref" citation line
        var lines = raw.components(separatedBy: "\n")
        var result: [String] = []
        for line in lines {
            if line.hasPrefix("!") {
                // Scripture citation — include as reference header
                let ref = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                result.append("[\(ref)]")
            } else {
                result.append(line)
            }
        }
        return result.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Psalm Schedule Loader

/// Loads the psalm antiphon/assignment schedule from Psalterium data files.
struct PsalmScheduleLoader {

    // MARK: - Lauds / Vespers (Major Hours)

    /// Antiphons and psalm numbers for Lauds on a given day of week (0=Sun, 1=Mon, …)
    static func laudsAntiphons(weekday: Int) -> [(antiphon: String, psalmNum: Int)] {
        let key = "Day\(weekday) Laudes1"
        return loadMajorAntiphons(key: key)
    }

    static func vesperAntiphons(weekday: Int) -> [(antiphon: String, psalmNum: Int)] {
        let key = "Day\(weekday) Vespera"
        return loadMajorAntiphons(key: key)
    }

    private static func loadMajorAntiphons(key: String) -> [(antiphon: String, psalmNum: Int)] {
        let sections = DataBundle.parse("Psalterium/Psalmi/Psalmi major.txt")
        guard let content = OfficeDataParser.section(named: key, in: sections) else { return [] }

        var result: [(String, Int)] = []
        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            let parts = trimmed.components(separatedBy: ";;")
            let antiphon = parts[0].trimmingCharacters(in: .whitespaces)
            if parts.count > 1 {
                let numStr = parts[1]
                    .components(separatedBy: "(")[0]  // strip verse range
                    .trimmingCharacters(in: .whitespaces)
                if let num = Int(numStr) {
                    result.append((antiphon, num))
                }
            }
        }
        return result
    }

    // MARK: - Matins (Major)

    struct MatinsNocturnData {
        let antiphons: [(antiphon: String, psalmNum: Int)]
        let versicle: String?
    }

    static func matinsAntiphons(weekday: Int) -> [MatinsNocturnData] {
        let sections = DataBundle.parse("Psalterium/Psalmi/Psalmi matutinum.txt")
        let dayKey = "Day\(weekday)"
        guard let content = OfficeDataParser.section(named: dayKey, in: sections) else {
            return []
        }

        var allAntiphons: [(String, Int)] = []
        var versicles: [String] = []
        var currentVersicle = ""
        var collectingVersicle = false

        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("V.") {
                collectingVersicle = true
                currentVersicle = trimmed
            } else if trimmed.hasPrefix("R.") && collectingVersicle {
                currentVersicle += "\n" + trimmed
                versicles.append(currentVersicle)
                collectingVersicle = false
                currentVersicle = ""
            } else if trimmed.contains(";;") {
                collectingVersicle = false
                let parts = trimmed.components(separatedBy: ";;")
                let antiphon = parts[0].trimmingCharacters(in: .whitespaces)
                if parts.count > 1 {
                    let numStr = parts[1]
                        .components(separatedBy: "(")[0]
                        .trimmingCharacters(in: .whitespaces)
                    if let num = Int(numStr) {
                        allAntiphons.append((antiphon, num))
                    }
                }
            }
        }

        // Split into 3 nocturns of 3 psalms each
        let grouped = stride(from: 0, to: min(allAntiphons.count, 9), by: 3).map {
            Array(allAntiphons[$0..<min($0 + 3, allAntiphons.count)])
        }

        return grouped.enumerated().map { idx, group in
            MatinsNocturnData(
                antiphons: group,
                versicle: idx < versicles.count ? versicles[idx] : nil
            )
        }
    }

    // MARK: - Little Hours

    struct LittleHourData {
        let antiphon: String
        let psalmNumbers: [Int]
    }

    static func littleHourData(hour: String, weekday: Int) -> LittleHourData? {
        let sections = DataBundle.parse("Psalterium/Psalmi/Psalmi minor.txt")
        guard let content = OfficeDataParser.section(named: hour, in: sections) else { return nil }

        // Parse: "DayName = antiphon\npsalm,psalm,psalm"
        let dayNames = ["Dominica", "Feria II", "Feria III", "Feria IV", "Feria V", "Feria VI", "Sabbato"]
        let targetDay = weekday < dayNames.count ? dayNames[weekday] : dayNames[0]

        var foundAntiphon: String? = nil
        var foundPsalms: [Int] = []
        var captureNext = false

        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if captureNext {
                // This line has psalm numbers
                foundPsalms = parsePsalmList(trimmed)
                break
            }

            if trimmed.hasPrefix(targetDay + " = ") || trimmed.hasPrefix(targetDay + "=") {
                let ant = trimmed
                    .replacingOccurrences(of: targetDay + " = ", with: "")
                    .replacingOccurrences(of: targetDay + "=", with: "")
                    .trimmingCharacters(in: .whitespaces)
                foundAntiphon = ant
                captureNext = true
            }
        }

        guard let antiphon = foundAntiphon else { return nil }
        return LittleHourData(antiphon: antiphon, psalmNumbers: foundPsalms)
    }

    private static func parsePsalmList(_ line: String) -> [Int] {
        line.components(separatedBy: ",").compactMap { part in
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            // Strip optional brackets [46] and verse ranges (1-16)
            let stripped = trimmed
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .components(separatedBy: "(")[0]
                .trimmingCharacters(in: .whitespaces)
            return Int(stripped)
        }
    }
}
