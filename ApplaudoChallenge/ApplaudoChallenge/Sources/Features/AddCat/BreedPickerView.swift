import NetworkLayer
import SwiftUI

struct BreedPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let breeds: [CatBreed]
    let onSelect: (CatBreed) -> Void

    @State private var searchText = ""

    private var filteredBreeds: [CatBreed] {
        if searchText.isEmpty { return breeds }
        return breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredBreeds) { breed in
                Button {
                    onSelect(breed)
                    dismiss()
                } label: {
                    Text(breed.name)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            .searchable(text: $searchText, prompt: "Search breeds")
            .navigationTitle("Select Breed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
