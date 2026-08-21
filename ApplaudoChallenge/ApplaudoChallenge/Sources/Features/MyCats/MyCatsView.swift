import SwiftData
import SwiftUI

struct MyCatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MyCatsViewModel()

    var body: some View {
        content
            .navigationTitle("My Cats")
            .navigationDestination(for: RegisteredCat.self) { cat in
                RegisteredCatDetailView(cat: cat)
            }
            .onAppear {
                viewModel.fetchCats(context: modelContext)
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.cats.isEmpty {
            EmptyStateView(
                systemImage: "pawprint",
                title: "No Cats Yet",
                message: "Use the Add Cat tab to register your first cat."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.cats, id: \.persistentModelID) { cat in
                        NavigationLink(value: cat) {
                            AppCard(
                                title: cat.name,
                                subtitle: "\(cat.breedName) \u{00B7} \(cat.age) years old",
                                imageSystemName: "pawprint",
                                imageData: cat.photo,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
    }
}
