import SwiftUI

struct AddCatDetailsView: View {
    @ObservedObject var viewModel: AddCatViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                SectionHeader(
                    title: "Details",
                    subtitle: "Tell us more about your cat",
                    systemImage: "info.circle"
                )

                AppTextField(
                    label: "Age",
                    placeholder: "Enter age (1-30)",
                    text: $viewModel.age,
                    errorMessage: viewModel.step2Errors["age"],
                    keyboardType: .numberPad,
                    icon: "calendar"
                )
                .onChange(of: viewModel.age) {
                    viewModel.clearStep2Error(for: "age")
                }

                AppTextField(
                    label: "Short Description",
                    placeholder: "Describe your cat (min 10 characters)",
                    text: $viewModel.shortDescription,
                    errorMessage: viewModel.step2Errors["shortDescription"],
                    icon: "text.alignleft"
                )
                .onChange(of: viewModel.shortDescription) {
                    viewModel.clearStep2Error(for: "shortDescription")
                }

                colorPicker

                genderPicker
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Coat Color")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(CatColor.allCases, id: \.self) { color in
                        Button {
                            viewModel.color = viewModel.color == color.rawValue ? "" : color.rawValue
                        } label: {
                            Text(color.displayName)
                                .font(AppTheme.Fonts.caption)
                                .foregroundColor(
                                    viewModel.color == color.rawValue
                                        ? .white
                                        : AppTheme.Colors.primary
                                )
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(
                                    viewModel.color == color.rawValue
                                        ? AppTheme.Colors.primary
                                        : AppTheme.Colors.primary.opacity(0.1)
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Gender")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Picker("Gender", selection: $viewModel.gender) {
                ForEach(CatGender.allCases, id: \.self) { gender in
                    Text(gender.displayName).tag(gender)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
