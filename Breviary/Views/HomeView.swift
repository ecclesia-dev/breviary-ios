import SwiftUI

struct HomeView: View {
    let viewModel: BreviaryViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    todayCard
                    currentHourCard
                    hoursGrid
                }
                .padding()
            }
            .background(BreviaryTheme.darkBg)
            .navigationTitle("Divine Office")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Today Card

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.today.formattedDate)
                .font(.subheadline)
                .foregroundStyle(BreviaryTheme.muted)

            Text(viewModel.today.name)
                .font(.title2.bold())
                .foregroundStyle(BreviaryTheme.cream)

            HStack(spacing: 12) {
                Label(viewModel.today.rank.displayName, systemImage: "star.fill")
                Label(viewModel.today.season.rawValue, systemImage: "leaf.fill")
                Label(viewModel.today.color.rawValue, systemImage: "circle.fill")
            }
            .font(.caption)
            .foregroundStyle(BreviaryTheme.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(BreviaryTheme.cardBg, in: .rect(cornerRadius: 16))
    }

    // MARK: - Current Hour Card

    private var currentHourCard: some View {
        NavigationLink {
            HourDetailView(office: viewModel.office(for: viewModel.currentHour))
        } label: {
            VStack(spacing: 12) {
                Image(systemName: viewModel.currentHour.systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(BreviaryTheme.gold)

                Text(viewModel.currentHour.name)
                    .font(.title3.bold())
                    .foregroundStyle(BreviaryTheme.cream)

                Text(viewModel.currentHour.latinName)
                    .font(.caption)
                    .foregroundStyle(BreviaryTheme.muted)

                Text("Pray Now")
                    .font(.caption.bold())
                    .foregroundStyle(BreviaryTheme.darkBg)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(BreviaryTheme.gold, in: Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(BreviaryTheme.cardBg, in: .rect(cornerRadius: 16))
        }
    }

    // MARK: - Hours Grid

    private var hoursGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Canonical Hours")
                .font(.headline)
                .foregroundStyle(BreviaryTheme.cream)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(CanonicalHour.allCases) { hour in
                    NavigationLink {
                        HourDetailView(office: viewModel.office(for: hour))
                    } label: {
                        HourCard(hour: hour, isCurrent: hour == viewModel.currentHour)
                    }
                }
            }
        }
    }
}

// MARK: - Hour Card

struct HourCard: View {
    let hour: CanonicalHour
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: hour.systemImage)
                .font(.title2)
                .foregroundStyle(isCurrent ? BreviaryTheme.gold : BreviaryTheme.muted)

            Text(hour.name)
                .font(.subheadline.bold())
                .foregroundStyle(BreviaryTheme.cream)

            Text(hour.latinName)
                .font(.caption2)
                .foregroundStyle(BreviaryTheme.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            isCurrent ? BreviaryTheme.gold.opacity(0.15) : BreviaryTheme.cardBg,
            in: .rect(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isCurrent ? BreviaryTheme.gold.opacity(0.5) : .clear, lineWidth: 1)
        )
    }
}
