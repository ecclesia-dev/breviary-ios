import Foundation

/// Loads and caches psalm texts from the Psalterium directory
@MainActor
final class PsalteriumLoader {
    static let shared = PsalteriumLoader()

    private var psalms: [Int: String] = [:]
    private var loaded = false

    private init() {}

    /// Load all psalms from the data directory
    func loadPsalms(from basePath: String) async {
        guard !loaded else { return }

        let result = await Task.detached(priority: .userInitiated) {
            Self.parsePsalmsFromDisk(basePath: basePath)
        }.value

        self.psalms = result
        self.loaded = true
    }

    /// Get psalm text by number
    func psalm(_ number: Int) -> String? {
        psalms[number]
    }

    // MARK: - Private

    nonisolated private static func parsePsalmsFromDisk(basePath: String) -> [Int: String] {
        var result: [Int: String] = [:]
        let fm = FileManager.default
        let psalmiPath = "\(basePath)/Psalterium/Psalmi"

        for filename in ["Psalmi_major.txt", "Psalmi_minor.txt", "Psalmi_matutinum.txt"] {
            let path = "\(psalmiPath)/\(filename)"
            guard let data = fm.contents(atPath: path),
                  let content = String(data: data, encoding: .utf8) else { continue }

            let sections = OfficeDataParser.parse(content)
            for section in sections {
                let cleaned = section.name
                    .replacingOccurrences(of: "Psalm ", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if let num = Int(cleaned) {
                    result[num] = section.content
                }
            }
        }

        return result
    }
}
