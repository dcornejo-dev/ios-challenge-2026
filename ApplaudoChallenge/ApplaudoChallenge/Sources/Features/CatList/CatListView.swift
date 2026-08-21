import NetworkLayer
import SwiftUI

struct CatListView: View {
    @StateObject private var viewModel = CatListViewModel()

    var body: some View {
        content
            .navigationTitle("Breeds")
            .navigationDestination(for: CatBreed.self) { breed in
                CatDetailView(breed: breed)
            }
            .task {
                if case .idle = viewModel.state {
                    viewModel.fetchBreeds()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let breeds) where breeds.isEmpty:
            EmptyStateView(
                systemImage: "cat",
                title: "No Breeds Found",
                message: "There are no cat breeds available at the moment."
            )

        case .loaded(let breeds):
            ScrollView {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(breeds) { breed in
                        NavigationLink(value: breed) {
                            AppCard(
                                title: breed.name,
                                subtitle: breed.description,
                                imageSystemName: "cat",
                                imageURL: breed.imageURL,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }

        case .error(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "Something Went Wrong",
                message: message,
                buttonTitle: "Try Again",
                action: { viewModel.fetchBreeds() }
            )
        }
    }
}
