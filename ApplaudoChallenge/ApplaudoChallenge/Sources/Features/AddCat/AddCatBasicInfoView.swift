import NetworkLayer
import PhotosUI
import SwiftUI

struct AddCatBasicInfoView: View {
    @ObservedObject var viewModel: AddCatViewModel

    @State private var showBreedPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                SectionHeader(
                    title: "Basic Information",
                    subtitle: "Enter your cat's name and breed",
                    systemImage: "cat"
                )

                photoPicker

                AppTextField(
                    label: "Cat Name",
                    placeholder: "Enter your cat's name",
                    text: $viewModel.name,
                    errorMessage: viewModel.step1Errors["name"],
                    icon: "pencil"
                )
                .onChange(of: viewModel.name) {
                    viewModel.clearStep1Error(for: "name")
                }

                breedSelector
            }
            .padding(AppTheme.Spacing.md)
        }
        .sheet(isPresented: $showBreedPicker) {
            breedPickerSheet
        }
    }

    private var photoPicker: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                if let photoData = viewModel.photo,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 2))
                } else {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.surface)
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 2))

                        VStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Add Photo")
                                .font(AppTheme.Fonts.caption)
                        }
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) {
                Task {
                    if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                        viewModel.photo = compressed
                    }
                }
            }

            if viewModel.photo != nil {
                Button {
                    viewModel.photo = nil
                    selectedPhotoItem = nil
                } label: {
                    Text("Remove Photo")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.error)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var breedSelector: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Breed")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Button {
                showBreedPicker = true
            } label: {
                HStack {
                    Image(systemName: "pawprint")
                        .foregroundColor(
                            viewModel.step1Errors["breed"] != nil
                                ? AppTheme.Colors.error
                                : AppTheme.Colors.textSecondary
                        )
                        .frame(width: 20)

                    Text(viewModel.breedName.isEmpty ? "Select a breed" : viewModel.breedName)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(
                            viewModel.breedName.isEmpty
                                ? AppTheme.Colors.textSecondary
                                : AppTheme.Colors.textPrimary
                        )

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.md)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(
                            viewModel.step1Errors["breed"] != nil
                                ? AppTheme.Colors.error
                                : AppTheme.Colors.border,
                            lineWidth: 1
                        )
                )
            }

            if let error = viewModel.step1Errors["breed"] {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                    Text(error)
                        .font(AppTheme.Fonts.caption)
                }
                .foregroundColor(AppTheme.Colors.error)
            }
        }
    }

    @ViewBuilder
    private var breedPickerSheet: some View {
        switch viewModel.breedsState {
        case .loaded(let breeds):
            BreedPickerView(breeds: breeds) { breed in
                viewModel.breedName = breed.name
                viewModel.breedId = breed.id
                viewModel.clearStep1Error(for: "breed")
            }
        case .loading:
            VStack {
                Spacer()
                ProgressView("Loading breeds...")
                Spacer()
            }
        case .error(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: "Failed to Load",
                message: message,
                buttonTitle: "Try Again"
            ) {
                viewModel.fetchBreeds()
            }
        case .idle:
            EmptyView()
        }
    }
}
