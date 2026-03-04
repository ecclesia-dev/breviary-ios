import Foundation

/// Loads and caches psalm texts from the bundled BreviaryData/Psalterium directory.
/// Uses Douay-Rheims psalm texts from divinum-officium-data.
@MainActor
final class PsalteriumLoader {
    static let shared = PsalteriumLoader()

    private var psalms: [Int: String] = [:]
    private(set) var loaded = false

    private init() {}

    // MARK: - Loading

    func loadAll() async {
        guard !loaded else { return }
        let result = await Task.detached(priority: .userInitiated) {
            Self.loadFromBundle()
        }.value
        psalms = result
        loaded = true
    }

    // MARK: - Access

    /// Get the full Douay-Rheims text of a psalm by number.
    func psalm(_ number: Int) -> String? {
        psalms[number]
    }

    /// Get psalm text, falling back to a descriptive reference if not found.
    func psalmText(_ number: Int) -> String {
        psalms[number] ?? "Psalm \(number)\n(See: Psalterium/Psalmorum/Psalm\(number).txt)"
    }

    // MARK: - Private Loading

    nonisolated private static func loadFromBundle() -> [Int: String] {
        var result: [Int: String] = [:]
        let fm = FileManager.default
        let psalmPath = DataBundle.root + "/Psalterium/Psalmorum"

        guard let items = try? fm.contentsOfDirectory(atPath: psalmPath) else {
            return result
        }

        for filename in items where filename.hasPrefix("Psalm") && filename.hasSuffix(".txt") {
            let path = psalmPath + "/" + filename
            guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { continue }
            // Extract number from "PsalmN.txt"
            let numStr = filename
                .replacingOccurrences(of: "Psalm", with: "")
                .replacingOccurrences(of: ".txt", with: "")
            if let num = Int(numStr) {
                result[num] = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return result
    }
}
