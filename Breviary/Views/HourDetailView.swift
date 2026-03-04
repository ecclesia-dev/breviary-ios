import SwiftUI

struct HourDetailView: View {
    let office: Office

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(office.hour.latinName)
                        .font(.caption)
                        .foregroundStyle(BreviaryTheme.gold)
                    Text(office.day.name)
                        .font(.subheadline)
                        .foregroundStyle(BreviaryTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(office.sections) { section in
                    PrayerSectionView(section: section)
                }
            }
            .padding()
        }
        .background(BreviaryTheme.darkBg)
        .navigationTitle(office.hour.name)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
