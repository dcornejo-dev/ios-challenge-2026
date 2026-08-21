import SwiftData
import SwiftUI

struct MyCatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MyCatsViewModel()
    @State private var showRegistrationSheet = false

    var body: some View {
        content
            .navigationTitle("My Cats")
            .toolbar {
                if !viewModel.cats.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showRegistrationSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Register a Cat")
                    }
                }
            }
            .navigationDestination(for: RegisteredCat.self) { cat in
                RegisteredCatDetailView(cat: cat)
            }
            .sheet(isPresented: $showRegistrationSheet) {
                viewModel.fetchCats(context: modelContext)
            } content: {
                AddCatStepperView()
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
                message: "Register your first cat to see it here.",
                buttonTitle: "Register a Cat",
                action: { showRegistrationSheet = true }
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
