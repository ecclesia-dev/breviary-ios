import Foundation

/// Access point for the bundled divinum-officium-data files.
/// In the app bundle, BreviaryData/ is a folder resource copied from opus/data.
enum DataBundle {

    /// Root path to BreviaryData inside the app bundle.
    static let root: String = {
        // When running as an app, resources are copied to bundle root.
        let bundlePath = Bundle.main.bundlePath
        let candidate = bundlePath + "/BreviaryData"
        if FileManager.default.fileExists(atPath: candidate) {
            return candidate
        }
        // Fallback: running from Xcode with source-tree layout
        let srcCandidate = Bundle.main.resourcePath.map { $0 + "/BreviaryData" } ?? candidate
        return srcCandidate
    }()

    // MARK: - File Loading

    /// Load a text file at a path relative to BreviaryData/.
    static func load(_ relativePath: String) -> String? {
        let fullPath = root + "/" + relativePath
        return try? String(contentsOfFile: fullPath, encoding: .utf8)
    }

    /// Parse a divinum-officium-data file into named sections.
    static func parse(_ relativePath: String) -> [OfficeDataParser.RawSection] {
        guard let content = load(relativePath) else { return [] }
        return OfficeDataParser.parse(content)
    }

    // MARK: - Psalm Loading

    /// Load a single psalm by number (Douay-Rheims, from Psalmorum/).
    static func psalm(_ number: Int) -> String? {
        load("Psalterium/Psalmorum/Psalm\(number).txt")
    }

    // MARK: - Common Prayers

    static let prayers: [String: String] = {
        let sections = parse("Psalterium/Common/Prayers.txt")
        var dict: [String: String] = [:]
        for s in sections { dict[s.name] = s.content }
        return dict
    }()

    static func prayer(_ name: String) -> String? {
        prayers[name]
    }
}
