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
            }
            .padding(AppTheme.Spacing.md)
        }
    }
}
