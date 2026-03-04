import SwiftUI

/// Main view model for the Breviary app
@Observable
@MainActor
final class BreviaryViewModel {
    var today: LiturgicalDay
    var currentHour: CanonicalHour
    var isLoading = true

    private let officeBuilder = OfficeBuilder()

    init() {
        let now = Date()
        self.today = LiturgicalCalendar.resolve(date: now)
        self.currentHour = CanonicalHour.current(at: now)
    }

    /// Load data and prepare for display
    func load() async {
        isLoading = true
        // TODO: Load psalterium from bundled divinum-officium-data
        // await PsalteriumLoader.shared.loadPsalms(from: dataPath)
        isLoading = false
    }

    /// Build office for a given hour
    func office(for hour: CanonicalHour) -> Office {
        officeBuilder.buildOffice(hour: hour, day: today)
    }

    /// Refresh the current day and hour (call on scene phase change)
    func refresh() {
        let now = Date()
        today = LiturgicalCalendar.resolve(date: now)
        currentHour = CanonicalHour.current(at: now)
    }
}
