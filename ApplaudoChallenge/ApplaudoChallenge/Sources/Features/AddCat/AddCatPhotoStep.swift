import PhotosUI
import SwiftUI

struct AddCatPhotoStep: View {
    @ObservedObject var viewModel: AddCatViewModel
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            reviewCard
            photoPickerSection
        }
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            reviewRow(label: "Name", value: viewModel.name)
            reviewRow(label: "Breed", value: viewModel.breedName)
            reviewRow(label: "Age", value: viewModel.age)
            reviewRow(label: "Description", value: viewModel.shortDescription)
            reviewRow(label: "Gender", value: viewModel.gender?.displayName ?? "")
            reviewRow(label: "Color", value: CatColor(rawValue: viewModel.color)?.displayName ?? viewModel.color)
        }
        .padding(AppTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    private func reviewRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Text(label)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var photoPickerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                photoTile
            }
            .buttonStyle(.plain)
            .onChange(of: selectedItem) { _, newItem in
                Task { await loadPhoto(from: newItem) }
            }

            HStack {
                Text("Optional — you can skip this and register anyway.")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Spacer()
                if viewModel.photo != nil {
                    Button {
                        viewModel.photo = nil
                        selectedItem = nil
                    } label: {
                        Text("Remove")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.xs)
        }
    }

    private var photoTile: some View {
        Group {
            if let photoData = viewModel.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Text("Add a photo")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .frame(width: 200, height: 200)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }

    @MainActor
    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            viewModel.photo = data
        }
    }
}
