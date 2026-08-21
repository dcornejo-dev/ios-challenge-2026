import SwiftUI

struct AddCatReviewView: View {
    @ObservedObject var viewModel: AddCatViewModel
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                SectionHeader(
                    title: "Review",
                    subtitle: "Confirm your cat's details",
                    systemImage: "checkmark.circle"
                )

                if let photoData = viewModel.photo,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 2))
                        .frame(maxWidth: .infinity)
                }

                reviewRow(title: "Name", value: viewModel.name, icon: "pencil")
                reviewRow(title: "Breed", value: viewModel.breedName, icon: "pawprint")
                reviewRow(title: "Age", value: "\(viewModel.age) years", icon: "calendar")
                reviewRow(title: "Description", value: viewModel.shortDescription, icon: "text.alignleft")

                if !viewModel.color.isEmpty,
                   let color = CatColor(rawValue: viewModel.color) {
                    reviewRow(title: "Coat Color", value: color.displayName, icon: "paintpalette")
                }

                reviewRow(title: "Gender", value: viewModel.gender.displayName, icon: "figure.stand")

                AppButton(title: "Save", action: onSave)
                    .padding(.top, AppTheme.Spacing.sm)
            }
            .padding(AppTheme.Spacing.md)
        }
    }

    private func reviewRow(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 20)

                Text(value)
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
        }
    }
}
