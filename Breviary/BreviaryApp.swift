import SwiftUI

@main
struct BreviaryApp: App {
    @State private var viewModel = BreviaryViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel)
                .task {
                    await viewModel.load()
                }
        }
    }
}
