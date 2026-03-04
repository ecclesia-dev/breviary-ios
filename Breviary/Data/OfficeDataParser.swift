import Foundation

/// Parses divinum-officium-data text files into structured sections
struct OfficeDataParser {

    /// A raw parsed section from a data file
    struct RawSection {
        let name: String
        let content: String
    }

    /// Parse a text file into named sections delimited by [SectionName]
    static func parse(_ text: String) -> [RawSection] {
        var sections: [RawSection] = []
        var currentName: String?
        var currentLines: [String] = []

        for line in text.components(separatedBy: .newlines) {
            if line.hasPrefix("[") && line.hasSuffix("]") {
                if let name = currentName {
                    let content = currentLines.joined(separator: "\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !content.isEmpty {
                        sections.append(RawSection(name: name, content: content))
                    }
                }
                currentName = String(line.dropFirst().dropLast())
                currentLines = []
            } else if currentName != nil {
                currentLines.append(line)
            }
        }

        // Save last section
        if let name = currentName {
            let content = currentLines.joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                sections.append(RawSection(name: name, content: content))
            }
        }

        return sections
    }

    /// Look up a section by name from parsed sections
    static func section(named name: String, in sections: [RawSection]) -> String? {
        sections.first { $0.name == name }?.content
    }

    /// Expand variable prayer endings ($Per Dominum, etc.)
    static func expandVariable(_ text: String) -> String {
        var result = text
        let expansions: [String: String] = [
            "$Per Dominum": "Per Dominum nostrum Jesum Christum, Filium tuum: qui tecum vivit et regnat in unitate Spiritus Sancti, Deus, per omnia saecula saeculorum. R. Amen.",
            "$Per eumdem": "Per eumdem Dominum nostrum Jesum Christum Filium tuum, qui tecum vivit et regnat in unitate Spiritus Sancti, Deus, per omnia saecula saeculorum. R. Amen.",
            "$Qui vivis": "Qui vivis et regnas cum Deo Patre in unitate Spiritus Sancti, Deus, per omnia saecula saeculorum. R. Amen.",
            "$Qui tecum": "Qui tecum vivit et regnat in unitate Spiritus Sancti, Deus, per omnia saecula saeculorum. R. Amen.",
            "$Deo gratias": "R. Deo gratias.",
        ]
        for (key, value) in expansions {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    /// Extract psalm numbers from a content line (e.g., "Antiphon text * rest;;109")
    static func extractPsalmReferences(_ line: String) -> [Int] {
        line.components(separatedBy: ";;")
            .dropFirst()
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }

    /// Extract antiphon text (before the ;; psalm reference)
    static func extractAntiphonText(_ line: String) -> String {
        if let range = line.range(of: ";;") {
            return String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return line.trimmingCharacters(in: .whitespaces)
    }
}
