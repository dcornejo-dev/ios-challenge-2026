import SwiftUI

struct AddCatDetailsStep: View {
    @ObservedObject var viewModel: AddCatViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            FloatingLabelField(
                label: "Age",
                text: $viewModel.age,
                helperText: "In years, 1–30. Round kittens under 1 year up to 1.",
                errorMessage: viewModel.step2Errors["age"],
                keyboardType: .numberPad
            )
            .onChange(of: viewModel.age) { _, _ in
                guard viewModel.step2Errors["age"] != nil else { return }
                if let ageInt = Int(viewModel.age), ageInt >= 1, ageInt <= 30 {
                    viewModel.clearStep2Error(for: "age")
                }
            }

            FloatingLabelField(
                label: "Short description",
                text: $viewModel.shortDescription,
                maxChars: 200,
                helperText: "10–200 characters.",
                errorMessage: viewModel.step2Errors["shortDescription"]
            )
            .onChange(of: viewModel.shortDescription) { _, _ in
                guard viewModel.step2Errors["shortDescription"] != nil else { return }
                let trimmed = viewModel.shortDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count >= 10 && trimmed.count <= 200 {
                    viewModel.clearStep2Error(for: "shortDescription")
                }
            }

            FloatingLabelField(
                label: "Color",
                helperText: "Main coat color or pattern.",
                errorMessage: viewModel.step2Errors["color"]
            ) {
                Menu {
                    ForEach(CatColor.allCases, id: \.self) { color in
                        Button(color.displayName) {
                            viewModel.color = color.rawValue
                            viewModel.clearStep2Error(for: "color")
                        }
                    }
                } label: {
                    HStack {
                        Text(colorDisplayText)
                            .foregroundColor(
                                viewModel.color.isEmpty
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

            FloatingLabelField(
                label: "Gender",
                helperText: "Male or Female.",
                errorMessage: viewModel.step2Errors["gender"]
            ) {
                Picker("Gender", selection: $viewModel.gender) {
                    Text("Male").tag(CatGender?.some(.male))
                    Text("Female").tag(CatGender?.some(.female))
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.gender) { _, newValue in
                    if newValue != nil {
                        viewModel.clearStep2Error(for: "gender")
                    }
                }
            }
        }
    }

    private var colorDisplayText: String {
        CatColor(rawValue: viewModel.color)?.displayName ?? "Select a color"
    }
}
