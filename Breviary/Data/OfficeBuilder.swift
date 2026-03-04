import Foundation

/// Builds a complete Office by assembling data from various sources
@MainActor
final class OfficeBuilder {
    private let psalterium: PsalteriumLoader

    init(psalterium: PsalteriumLoader = .shared) {
        self.psalterium = psalterium
    }

    /// Build the office for a given hour and day.
    /// Currently uses placeholder content; full implementation will load from divinum-officium-data.
    func buildOffice(hour: CanonicalHour, day: LiturgicalDay) -> Office {
        var sections: [OfficeSection] = []

        sections.append(OfficeSection(
            type: .versicle,
            title: "Opening",
            content: hour.openingVersicle
        ))

        switch hour {
        case .matins:   sections.append(contentsOf: buildMatins(day: day))
        case .lauds:    sections.append(contentsOf: buildLauds(day: day))
        case .prime:    sections.append(contentsOf: buildLittleHour(name: "Prime", day: day))
        case .terce:    sections.append(contentsOf: buildLittleHour(name: "Terce", day: day))
        case .sext:     sections.append(contentsOf: buildLittleHour(name: "Sext", day: day))
        case .none:     sections.append(contentsOf: buildLittleHour(name: "None", day: day))
        case .vespers:  sections.append(contentsOf: buildVespers(day: day))
        case .compline: sections.append(contentsOf: buildCompline(day: day))
        }

        sections.append(OfficeSection(
            type: .versicle,
            title: "Conclusion",
            content: "V. Fidelium animae, per misericordiam Dei, requiescant in pace.\nR. Amen."
        ))

        return Office(hour: hour, day: day, sections: sections)
    }

    // MARK: - Matins

    private func buildMatins(day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        s.append(OfficeSection(
            type: .invitatory,
            title: "Invitatory",
            content: "Dominum, qui fecit nos, * Venite, adoremus.\n\nPsalm 94 — Venite, exsultemus Domino"
        ))

        s.append(OfficeSection(
            type: .hymn,
            title: "Hymn",
            content: "Hymn for \(day.season.rawValue) season\n\n(Full hymn text loaded from data files)"
        ))

        for nocturn in 1...3 {
            s.append(OfficeSection(type: .rubric, title: "Nocturn \(nocturn)", content: "Nocturn \(nocturn)"))

            for psalm in 1...3 {
                s.append(OfficeSection(type: .antiphon, title: "Antiphon \(psalm)", content: "Antiphon \(psalm) of Nocturn \(nocturn)"))
                s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Psalm text loaded from Psalterium)"))
            }

            s.append(OfficeSection(type: .versicle, content: "V. Versicle of Nocturn \(nocturn)\nR. Response"))

            for reading in 1...3 {
                let num = (nocturn - 1) * 3 + reading
                s.append(OfficeSection(type: .reading, title: "Lectio \(num)", content: "(Reading \(num) loaded from data files)"))
                s.append(OfficeSection(type: .responsory, title: "Responsory \(num)", content: "(Responsory loaded from data files)"))
            }
        }

        s.append(OfficeSection(
            type: .canticle,
            title: "Te Deum",
            content: "Te Deum laudamus: * te Dominum confitemur.\nTe aeternum Patrem, * omnis terra veneratur."
        ))

        return s
    }

    // MARK: - Lauds

    private func buildLauds(day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        s.append(OfficeSection(type: .hymn, title: "Hymn", content: "Hymn for Lauds — \(day.season.rawValue)"))

        for i in 1...5 {
            s.append(OfficeSection(type: .antiphon, title: "Antiphon \(i)", content: "Antiphon \(i) for Lauds"))
            s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Psalm text loaded from Psalterium)"))
        }

        s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: "(Chapter text loaded from data files)"))
        s.append(OfficeSection(type: .responsoryBreve, title: "Short Responsory", content: "(Short responsory loaded from data files)"))

        s.append(OfficeSection(type: .antiphon, title: "Antiphon at Benedictus", content: "Antiphon for the Benedictus"))
        s.append(OfficeSection(
            type: .canticle,
            title: "Benedictus",
            content: "Benedictus Dominus Deus Israel, * quia visitavit et fecit redemptionem plebis suae."
        ))

        s.append(OfficeSection(type: .collect, title: "Collect", content: "Collect prayer for \(day.name)"))

        return s
    }

    // MARK: - Little Hours (Prime, Terce, Sext, None)

    private func buildLittleHour(name: String, day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        s.append(OfficeSection(type: .hymn, title: "Hymn", content: "Hymn for \(name)"))

        for i in 1...3 {
            s.append(OfficeSection(type: .antiphon, title: "Antiphon", content: "Antiphon for \(name)"))
            s.append(OfficeSection(type: .psalm, title: "Psalm \(i)", content: "(Psalm text loaded from Psalterium)"))
        }

        s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: "(Chapter text loaded from data files)"))
        s.append(OfficeSection(type: .responsoryBreve, title: "Short Responsory", content: "(Short responsory loaded from data files)"))
        s.append(OfficeSection(type: .versicle, content: "V. Versicle for \(name)\nR. Response"))
        s.append(OfficeSection(type: .collect, title: "Collect", content: "Collect prayer for \(day.name)"))

        return s
    }

    // MARK: - Vespers

    private func buildVespers(day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        for i in 1...5 {
            s.append(OfficeSection(type: .antiphon, title: "Antiphon \(i)", content: "Antiphon \(i) for Vespers"))
            s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Psalm text loaded from Psalterium)"))
        }

        s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: "(Chapter text loaded from data files)"))
        s.append(OfficeSection(type: .hymn, title: "Hymn", content: "Hymn for Vespers — \(day.season.rawValue)"))
        s.append(OfficeSection(type: .versicle, content: "V. Versicle for Vespers\nR. Response"))

        s.append(OfficeSection(type: .antiphon, title: "Antiphon at Magnificat", content: "Antiphon for the Magnificat"))
        s.append(OfficeSection(
            type: .canticle,
            title: "Magnificat",
            content: "Magnificat * anima mea Dominum.\nEt exsultavit spiritus meus * in Deo salutari meo."
        ))

        s.append(OfficeSection(type: .collect, title: "Collect", content: "Collect prayer for \(day.name)"))

        return s
    }

    // MARK: - Compline

    private func buildCompline(day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        s.append(OfficeSection(
            type: .reading,
            title: "Short Reading",
            content: "Fratres: Sobrii estote, et vigilate: quia adversarius vester diabolus tamquam leo rugiens circuit, quaerens quem devoret: cui resistite fortes in fide.\nTu autem, Domine, miserere nobis. R. Deo gratias."
        ))

        s.append(OfficeSection(
            type: .preces,
            title: "Confiteor",
            content: "Confiteor Deo omnipotenti, beatae Mariae semper Virgini, beato Michaeli Archangelo, beato Joanni Baptistae, sanctis Apostolis Petro et Paulo, omnibus Sanctis, et vobis, fratres: quia peccavi nimis cogitatione, verbo et opere: mea culpa, mea culpa, mea maxima culpa."
        ))

        s.append(OfficeSection(
            type: .hymn,
            title: "Te lucis ante terminum",
            content: "Te lucis ante terminum,\nRerum Creator, poscimus,\nUt pro tua clementia\nSis praesul et custodia.\n\nProcul recedant somnia,\nEt noctium phantasmata;\nHostemque nostrum comprime,\nNe polluantur corpora.\n\nPraesta, Pater piissime,\nPatrique compar Unice,\nCum Spiritu Paraclito\nRegnans per omne saeculum. Amen."
        ))

        for psalm in ["4", "30", "90", "133"] {
            s.append(OfficeSection(type: .psalm, title: "Psalm \(psalm)", content: "(Psalm \(psalm) text loaded from Psalterium)"))
        }

        s.append(OfficeSection(
            type: .canticle,
            title: "Nunc Dimittis",
            content: "Nunc dimittis servum tuum, Domine, * secundum verbum tuum in pace:\nQuia viderunt oculi mei * salutare tuum,\nQuod parasti * ante faciem omnium populorum:\nLumen ad revelationem gentium, * et gloriam plebis tuae Israel."
        ))

        s.append(OfficeSection(
            type: .collect,
            title: "Collect",
            content: "Visita, quaesumus, Domine, habitationem istam, et omnes insidias inimici ab ea longe repelle: Angeli tui sancti habitent in ea, qui nos in pace custodiant; et benedictio tua sit super nos semper, per Dominum.\nR. Amen."
        ))

        s.append(OfficeSection(
            type: .antiphon,
            title: "Marian Antiphon",
            content: marianAntiphon(for: day.season)
        ))

        return s
    }

    // MARK: - Marian Antiphons by Season

    private func marianAntiphon(for season: LiturgicalSeason) -> String {
        switch season {
        case .advent, .christmas:
            return "Alma Redemptoris Mater, quae pervia caeli porta manes, et stella maris, succurre cadenti, surgere qui curat, populo: tu quae genuisti, natura mirante, tuum sanctum Genitorem, Virgo prius ac posterius, Gabrielis ab ore sumens illud Ave, peccatorum miserere."
        case .epiphany, .septuagesima:
            return "Ave, Regina caelorum, ave, Domina Angelorum: salve, radix, salve, porta, ex qua mundo lux est orta: Gaude, Virgo gloriosa, super omnes speciosa: vale, o valde decora, et pro nobis Christum exora."
        case .lent, .passiontide:
            return "Ave, Regina caelorum, ave, Domina Angelorum: salve, radix, salve, porta, ex qua mundo lux est orta: Gaude, Virgo gloriosa, super omnes speciosa: vale, o valde decora, et pro nobis Christum exora."
        case .easter:
            return "Regina caeli, laetare, alleluia. Quia quem meruisti portare, alleluia. Resurrexit, sicut dixit, alleluia. Ora pro nobis Deum, alleluia."
        case .pentecost:
            return "Salve, Regina, Mater misericordiae, vita, dulcedo, et spes nostra, salve. Ad te clamamus, exsules filii Hevae, ad te suspiramus, gementes et flentes in hac lacrimarum valle. Eia, ergo, advocata nostra, illos tuos misericordes oculos ad nos converte; et Jesum, benedictum fructum ventris tui, nobis post hoc exsilium ostende. O clemens, O pia, O dulcis Virgo Maria."
        }
    }
}
