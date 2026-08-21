import SwiftUI

struct AddCatIdentityStep: View {
    @ObservedObject var viewModel: AddCatViewModel
    @State private var showBreedPicker = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            FloatingLabelField(
                label: "Name",
                text: $viewModel.name,
                helperText: "Your cat's name.",
                errorMessage: viewModel.step1Errors["name"],
                contentType: .name
            )
            .onChange(of: viewModel.name) { _, _ in
                if viewModel.step1Errors["name"] != nil {
                    let trimmed = viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.count >= 2 && trimmed.count <= 30 {
                        viewModel.clearStep1Error(for: "name")
                    }
                }
            }

            FloatingLabelField(
                label: "Breed",
                helperText: "Pick a breed from the list.",
                errorMessage: viewModel.step1Errors["breed"]
            ) {
                Button {
                    showBreedPicker = true
                } label: {
                    HStack {
                        Text(viewModel.breedName.isEmpty ? "Select a breed" : viewModel.breedName)
                            .foregroundColor(
                                viewModel.breedName.isEmpty
                                    ? AppTheme.Colors.textSecondary
                                    : AppTheme.Colors.textPrimary
                            )
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .font(AppTheme.Fonts.body)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showBreedPicker) {
            BreedPickerSheet(viewModel: viewModel)
        }
    }
}
