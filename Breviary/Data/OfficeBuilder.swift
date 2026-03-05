import Foundation

/// Builds a complete Office by assembling data from BreviaryData bundle files.
/// Uses TemporaLoader for feast/feria content and PsalmScheduleLoader for
/// the weekly psalm cycle from the Psalterium.
@MainActor
final class OfficeBuilder {
    private let psalterium: PsalteriumLoader

    init(psalterium: PsalteriumLoader = .shared) {
        self.psalterium = psalterium
    }

    // MARK: - Public

    /// Build the office for a given hour and day.
    func buildOffice(hour: CanonicalHour, day: LiturgicalDay) -> Office {
        let loader = TemporaLoader(day: day)
        var sections: [OfficeSection] = []

        sections.append(OfficeSection(
            type: .versicle,
            title: "Opening",
            content: hour.openingVersicle
        ))

        switch hour {
        case .matins:   sections.append(contentsOf: buildMatins(day: day, loader: loader))
        case .lauds:    sections.append(contentsOf: buildLauds(day: day, loader: loader))
        case .prime:    sections.append(contentsOf: buildLittleHour(name: "Prime",  hourKey: "Prime",  day: day, loader: loader))
        case .terce:    sections.append(contentsOf: buildLittleHour(name: "Terce",  hourKey: "Tertia", day: day, loader: loader))
        case .sext:     sections.append(contentsOf: buildLittleHour(name: "Sext",   hourKey: "Sexta",  day: day, loader: loader))
        case .none:     sections.append(contentsOf: buildLittleHour(name: "None",   hourKey: "Nona",   day: day, loader: loader))
        case .vespers:  sections.append(contentsOf: buildVespers(day: day, loader: loader))
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

    private func buildMatins(day: LiturgicalDay, loader: TemporaLoader) -> [OfficeSection] {
        var s: [OfficeSection] = []
        let weekday = Calendar.current.component(.weekday, from: day.date) - 1 // 0=Sun

        // Invitatory
        let invitatoryText = DataBundle.parse("Sancti/\(day.sanctiFile ?? "").txt")
            .first(where: { $0.name == "Invit" })?.content
            ?? DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
                .first(where: { $0.name == "Invit" })?.content
            ?? "Dominum, qui fecit nos, * Venite, adoremus.\n\nPsalm 94 — Venite, exsultemus Domino"
        s.append(OfficeSection(type: .invitatory, title: "Invitatory", content: invitatoryText))

        // Hymn
        if let hymn = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Hymnus Matutinum" || $0.name == "HymnusM Matutinum" })?.content {
            s.append(OfficeSection(type: .hymn, title: "Hymn", content: hymn))
        } else if let hymn = loader.officiumName.map({ "Hymn for \($0)" }) {
            s.append(OfficeSection(type: .hymn, title: "Hymn", content: hymn))
        }

        // Three Nocturns
        let nocturnData = PsalmScheduleLoader.matinsAntiphons(weekday: weekday)
        for (nocturnIdx, nocturn) in nocturnData.enumerated() {
            let nocturnNum = nocturnIdx + 1
            s.append(OfficeSection(type: .rubric, title: "Nocturn \(nocturnNum)", content: "Nocturn \(nocturnNum)"))

            for (pairIdx, pair) in nocturn.antiphons.enumerated() {
                s.append(OfficeSection(
                    type: .antiphon,
                    title: "Antiphon \(pairIdx + 1)",
                    content: pair.antiphon
                ))
                s.append(OfficeSection(
                    type: .psalm,
                    title: "Psalm \(pair.psalmNum)",
                    content: psalterium.psalmText(pair.psalmNum)
                ))
            }

            if let versicle = nocturn.versicle {
                s.append(OfficeSection(type: .versicle, content: versicle))
            }

            for readingPos in 1...3 {
                let readingNum = (nocturnIdx * 3) + readingPos
                if let text = loader.reading(readingNum) {
                    s.append(OfficeSection(type: .reading, title: "Lectio \(readingNum)", content: text))
                }
                if let resp = loader.responsory(readingNum) {
                    s.append(OfficeSection(type: .responsory, title: "Responsory \(readingNum)", content: resp))
                }
            }
        }

        // If no nocturn data found, use placeholder structure
        if nocturnData.isEmpty {
            for nocturn in 1...3 {
                s.append(OfficeSection(type: .rubric, title: "Nocturn \(nocturn)", content: "Nocturn \(nocturn)"))
                for psalm in 1...3 {
                    s.append(OfficeSection(type: .antiphon, title: "Antiphon \(psalm)", content: loader.antiphon1 ?? "Antiphon \(psalm)"))
                    s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(See Psalterium)"))
                }
                for reading in 1...3 {
                    let num = (nocturn - 1) * 3 + reading
                    s.append(OfficeSection(
                        type: .reading,
                        title: "Lectio \(num)",
                        content: loader.reading(num) ?? "(Reading \(num))"
                    ))
                    s.append(OfficeSection(
                        type: .responsory,
                        title: "Responsory \(num)",
                        content: loader.responsory(num) ?? "(Responsory \(num))"
                    ))
                }
            }
        }

        // Te Deum (Sundays and feasts)
        s.append(OfficeSection(
            type: .canticle,
            title: "Te Deum",
            content: DataBundle.prayer("Te Deum")
                ?? "Te Deum laudamus: * te Dominum confitemur.\nTe aeternum Patrem, * omnis terra veneratur."
        ))

        return s
    }

    // MARK: - Lauds

    private func buildLauds(day: LiturgicalDay, loader: TemporaLoader) -> [OfficeSection] {
        var s: [OfficeSection] = []
        let weekday = Calendar.current.component(.weekday, from: day.date) - 1

        // Hymn
        let hymnKey = "Hymnus Laudes"
        if let hymn = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == hymnKey })?.content {
            s.append(OfficeSection(type: .hymn, title: "Hymn", content: hymn))
        }

        // Antiphons and psalms from Psalterium weekly cycle
        let antiphons = PsalmScheduleLoader.laudsAntiphons(weekday: weekday)
        // Feast antiphons override psaltry if available
        let feastAntiphons = loader.antiphonLaudes

        for (idx, pair) in antiphons.enumerated() {
            let antiphon = idx < feastAntiphons.count
                ? feastAntiphons[idx]
                : pair.antiphon
            s.append(OfficeSection(type: .antiphon, title: "Antiphon \(idx + 1)", content: antiphon))
            s.append(OfficeSection(
                type: .psalm,
                title: "Psalm \(pair.psalmNum)",
                content: psalterium.psalmText(pair.psalmNum)
            ))
        }

        if antiphons.isEmpty {
            // Fallback if psalm schedule not found
            for (idx, ant) in feastAntiphons.prefix(5).enumerated() {
                s.append(OfficeSection(type: .antiphon, title: "Antiphon \(idx + 1)", content: ant))
                s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Psalm from weekly cycle)"))
            }
        }

        // Chapter (Capitulum)
        if let cap = loader.capitulumLaudes {
            s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: cap))
        }

        // Short Responsory
        if let resp = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Responsory Laudes" })?.content {
            s.append(OfficeSection(type: .responsoryBreve, title: "Short Responsory", content: resp))
        }

        // Benedictus antiphon
        let benAntiphon = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Ant Laudes" || $0.name == "Ant 3" })?.content
            ?? loader.antiphon1 ?? "Antiphon at Benedictus"
        s.append(OfficeSection(type: .antiphon, title: "Antiphon at Benedictus", content: benAntiphon))
        s.append(OfficeSection(
            type: .canticle,
            title: "Benedictus",
            content: DataBundle.prayer("Benedictus")
                ?? "Benedictus Dominus Deus Israel, * quia visitavit et fecit redemptionem plebis suae."
        ))

        // Collect
        if let collect = loader.collect {
            s.append(OfficeSection(type: .collect, title: "Collect", content: collect))
        } else {
            s.append(OfficeSection(type: .collect, title: "Collect", content: "Collect for \(day.name)"))
        }

        return s
    }

    // MARK: - Little Hours (Prime, Terce, Sext, None)

    private func buildLittleHour(name: String, hourKey: String, day: LiturgicalDay, loader: TemporaLoader) -> [OfficeSection] {
        var s: [OfficeSection] = []
        let weekday = Calendar.current.component(.weekday, from: day.date) - 1

        // Hymn
        if let hymn = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Hymnus \(hourKey)" })?.content {
            s.append(OfficeSection(type: .hymn, title: "Hymn", content: hymn))
        }

        // Psalms from minor psalm schedule
        if let data = PsalmScheduleLoader.littleHourData(hour: hourKey, weekday: weekday) {
            s.append(OfficeSection(type: .antiphon, title: "Antiphon", content: data.antiphon))
            for num in data.psalmNumbers {
                s.append(OfficeSection(
                    type: .psalm,
                    title: "Psalm \(num)",
                    content: psalterium.psalmText(num)
                ))
            }
        } else {
            s.append(OfficeSection(type: .antiphon, title: "Antiphon", content: "Antiphon for \(name)"))
            s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Psalms from weekly cycle)"))
        }

        // Chapter
        if let cap = loader.capitulumNona {
            s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: cap))
        }

        // Short Responsory
        if let resp = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Responsory \(hourKey)" })?.content {
            s.append(OfficeSection(type: .responsoryBreve, title: "Short Responsory", content: resp))
        }

        // Collect
        if let collect = loader.collect {
            s.append(OfficeSection(type: .collect, title: "Collect", content: collect))
        }

        return s
    }

    // MARK: - Vespers

    private func buildVespers(day: LiturgicalDay, loader: TemporaLoader) -> [OfficeSection] {
        var s: [OfficeSection] = []
        let weekday = Calendar.current.component(.weekday, from: day.date) - 1

        // Psalm antiphons from weekly cycle
        let antiphons = PsalmScheduleLoader.vesperAntiphons(weekday: weekday)
        // Feast antiphons override if available
        let feastAntiphons: [String] = {
            guard let raw = DataBundle.parse("Sancti/\(day.sanctiFile ?? "").txt")
                .first(where: { $0.name == "Ant Vespera" })?.content else { return [] }
            return raw.components(separatedBy: "\n")
                .map { OfficeDataParser.extractAntiphonText($0) }
                .filter { !$0.isEmpty }
        }()

        for (idx, pair) in antiphons.enumerated() {
            let antiphon = idx < feastAntiphons.count
                ? feastAntiphons[idx]
                : pair.antiphon
            s.append(OfficeSection(type: .antiphon, title: "Antiphon \(idx + 1)", content: antiphon))
            s.append(OfficeSection(
                type: .psalm,
                title: "Psalm \(pair.psalmNum)",
                content: psalterium.psalmText(pair.psalmNum)
            ))
        }

        if antiphons.isEmpty {
            for (idx, ant) in feastAntiphons.prefix(5).enumerated() {
                s.append(OfficeSection(type: .antiphon, title: "Antiphon \(idx + 1)", content: ant))
                s.append(OfficeSection(type: .psalm, title: "Psalm", content: "(Vesper psalm)"))
            }
        }

        // Chapter
        if let cap = loader.capitulumLaudes {
            s.append(OfficeSection(type: .chapter, title: "Little Chapter", content: cap))
        }

        // Hymn
        if let hymn = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Hymnus Vespera" || $0.name == "HymnusM Vespera" })?.content
            ?? DataBundle.parse("Sancti/\(day.sanctiFile ?? "").txt")
                .first(where: { $0.name == "Hymnus Vespera" })?.content {
            s.append(OfficeSection(type: .hymn, title: "Hymn", content: hymn))
        }

        // Versicle
        if let versicle = DataBundle.parse("Tempora/\(day.temporaFile ?? "").txt")
            .first(where: { $0.name == "Versum 1" })?.content {
            s.append(OfficeSection(type: .versicle, content: versicle))
        }

        // Magnificat antiphon
        let magAntiphon = loader.antiphon2 ?? "Antiphon at Magnificat"
        s.append(OfficeSection(type: .antiphon, title: "Antiphon at Magnificat", content: magAntiphon))
        s.append(OfficeSection(
            type: .canticle,
            title: "Magnificat",
            content: DataBundle.prayer("Magnificat")
                ?? "Magnificat * anima mea Dominum.\nEt exsultavit spiritus meus * in Deo salutari meo."
        ))

        // Collect
        if let collect = loader.collect {
            s.append(OfficeSection(type: .collect, title: "Collect", content: collect))
        }

        return s
    }

    // MARK: - Compline (fixed office — same every night)

    private func buildCompline(day: LiturgicalDay) -> [OfficeSection] {
        var s: [OfficeSection] = []

        s.append(OfficeSection(
            type: .reading,
            title: "Short Reading (1 Pet 5:8-9)",
            content: "Fratres: Sobrii estote, et vigilate: quia adversarius vester diabolus tamquam leo rugiens circuit, quaerens quem devoret: cui resistite fortes in fide.\nTu autem, Domine, miserere nobis. R. Deo gratias."
        ))

        // M3: The key in Prayers.txt is "Confiteor_" (with underscore), not "Confiteor".
        // Fallback is the complete Roman Rite Latin text — both halves of the prayer.
        s.append(OfficeSection(
            type: .preces,
            title: "Confiteor",
            content: DataBundle.prayer("Confiteor_")
                ?? "Confiteor Deo omnipotenti, beatae Mariae semper Virgini, beato Michaeli Archangelo, beato Joanni Baptistae, sanctis Apostolis Petro et Paulo, omnibus Sanctis, et vobis, fratres: quia peccavi nimis cogitatione, verbo et opere: mea culpa, mea culpa, mea maxima culpa. Ideo precor beatam Mariam semper Virginem, beatum Michaelem Archangelum, beatum Joannem Baptistam, sanctos Apostolos Petrum et Paulum, omnes Sanctos, et vos, fratres, orare pro me ad Dominum Deum nostrum."
        ))

        s.append(OfficeSection(
            type: .hymn,
            title: "Te lucis ante terminum",
            content: "Te lucis ante terminum,\nRerum Creator, poscimus,\nUt pro tua clementia\nSis praesul et custodia.\n\nProcul recedant somnia,\nEt noctium phantasmata;\nHostemque nostrum comprime,\nNe polluantur corpora.\n\nPraesta, Pater piissime,\nPatrique compar Unice,\nCum Spiritu Paraclito\nRegnans per omne saeculum. Amen."
        ))

        for psalmNum in [4, 30, 90, 133] {
            s.append(OfficeSection(
                type: .psalm,
                title: "Psalm \(psalmNum)",
                content: psalterium.psalmText(psalmNum)
            ))
        }

        s.append(OfficeSection(
            type: .canticle,
            title: "Nunc Dimittis",
            content: DataBundle.prayer("Nunc dimittis")
                ?? "Nunc dimittis servum tuum, Domine, * secundum verbum tuum in pace:\nQuia viderunt oculi mei * salutare tuum."
        ))

        s.append(OfficeSection(
            type: .collect,
            title: "Collect",
            content: "Visita, quaesumus, Domine, habitationem istam, et omnes insidias inimici ab ea longe repelle: Angeli tui sancti habitent in ea, qui nos in pace custodiant; et benedictio tua sit super nos semper, per Dominum.\nR. Amen."
        ))

        s.append(OfficeSection(
            type: .antiphon,
            title: "Marian Antiphon",
            content: marianAntiphon(for: day)
        ))

        return s
    }

    // MARK: - Marian Antiphons by Season (1962 rubrics)
    //
    // Per the 1962 Roman Rite:
    //   Alma Redemptoris Mater  — First Vespers of Advent through Compline of Feb 2 (Purification)
    //   Ave Regina Caelorum     — Feb 2 (after Compline) through Wednesday of Holy Week
    //   Regina Caeli            — Easter through Pentecost (inclusive)
    //   Salve Regina            — Trinity Sunday through None of last Saturday before Advent
    //
    // The season enum alone is insufficient because the Epiphany season straddles the
    // Feb 2 boundary; the actual calendar date must decide which antiphon is used.

    private func marianAntiphon(for day: LiturgicalDay) -> String {
        let cal = Calendar.current
        let month = cal.component(.month, from: day.date)
        let dayOfMonth = cal.component(.day, from: day.date)

        switch day.season {
        case .advent, .christmas:
            return "Alma Redemptoris Mater, quae pervia caeli porta manes, et stella maris, succurre cadenti, surgere qui curat, populo: tu quae genuisti, natura mirante, tuum sanctum Genitorem, Virgo prius ac posterius, Gabrielis ab ore sumens illud Ave, peccatorum miserere."
        case .epiphany, .septuagesima:
            // Alma Redemptoris Mater through Compline of Feb 2 (Purification of the B.V.M.);
            // Ave Regina Caelorum from Feb 3 onward.
            if month == 1 || (month == 2 && dayOfMonth <= 2) {
                return "Alma Redemptoris Mater, quae pervia caeli porta manes, et stella maris, succurre cadenti, surgere qui curat, populo: tu quae genuisti, natura mirante, tuum sanctum Genitorem, Virgo prius ac posterius, Gabrielis ab ore sumens illud Ave, peccatorum miserere."
            }
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
