import NetworkLayer
import SwiftUI

struct CatDetailView: View {

    let breed: CatBreed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                breedImage
                detailSections
            }
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var breedImage: some View {
        Color.clear
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                if let imageURL = breed.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            imagePlaceholder
                        case .empty:
                            ProgressView()
                        @unknown default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
            }
            .clipped()
    }

    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.Colors.surface
            Image(systemName: "cat")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    private var detailSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            textSection(title: "Description", systemImage: "text.alignleft", text: breed.description)
            textSection(title: "Origin", systemImage: "globe", text: breed.origin)
            temperamentSection
            textSection(title: "Life Span", systemImage: "heart", text: "\(breed.lifeSpan) years")
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    private func textSection(title: String, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(title: title, systemImage: systemImage)
            Text(text)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }

    private var temperamentSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(title: "Temperament", systemImage: "sparkles")
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100))],
                alignment: .leading,
                spacing: AppTheme.Spacing.sm
            ) {
                ForEach(breed.temperamentTraits, id: \.self) { trait in
                    ChipView(title: trait)
                }
            }
        }
    }
}

#if DEBUG
    #Preview("Cat Detail View") {
        NavigationStack {
            CatDetailView(breed: .preview)
        }
    }
#endif
