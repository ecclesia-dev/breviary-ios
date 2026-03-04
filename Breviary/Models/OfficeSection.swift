import Foundation

/// Types of sections that appear in an office
enum OfficeSectionType: String {
    case invitatory = "Invitatorium"
    case hymn = "Hymnus"
    case antiphon = "Antiphona"
    case psalm = "Psalmus"
    case chapter = "Capitulum"
    case responsory = "Responsorium"
    case responsoryBreve = "Responsorium Breve"
    case versicle = "Versiculum"
    case canticle = "Canticum"
    case reading = "Lectio"
    case collect = "Oratio"
    case commemoration = "Commemoratio"
    case rubric = "Rubrica"
    case doxology = "Gloria Patri"
    case preces = "Preces"
    case benediction = "Benedictio"
}

/// A single section of the Divine Office
struct OfficeSection: Identifiable {
    let id = UUID()
    let type: OfficeSectionType
    let title: String
    let content: String
    let latinContent: String?
    let rubric: String?

    init(
        type: OfficeSectionType,
        title: String = "",
        content: String,
        latinContent: String? = nil,
        rubric: String? = nil
    ) {
        self.type = type
        self.title = title.isEmpty ? type.rawValue : title
        self.content = content
        self.latinContent = latinContent
        self.rubric = rubric
    }
}
