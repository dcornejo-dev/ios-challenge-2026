import NetworkLayer
import SwiftUI

struct BreedPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddCatViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Select a breed")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
        .task {
            if case .idle = viewModel.breedsState {
                viewModel.fetchBreeds()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.breedsState {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let breeds):
            let filtered = filter(breeds)
            if filtered.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No matches",
                    message: "Try a different search term."
                )
                .searchable(text: $searchText, prompt: "Search breeds")
            } else {
                List(filtered) { breed in
                    Button {
                        viewModel.breedName = breed.name
                        viewModel.breedId = breed.id
                        viewModel.clearStep1Error(for: "breed")
                        dismiss()
                    } label: {
                        HStack {
                            Text(breed.name)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            if breed.id == viewModel.breedId {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search breeds")
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

    private func filter(_ breeds: [CatBreed]) -> [CatBreed] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return breeds }
        return breeds.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
}
