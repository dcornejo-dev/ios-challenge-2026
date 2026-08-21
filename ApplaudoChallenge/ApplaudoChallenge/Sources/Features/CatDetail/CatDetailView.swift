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
                    CachedAsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        imagePlaceholder
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
            if let origin = breed.origin {
                textSection(title: "Origin", systemImage: "globe", text: origin)
            }
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
            SectionHeader(title: "Temperament", systemImage: "brain.head.profile")
            FlowLayout(spacing: AppTheme.Spacing.sm) {
                ForEach(breed.temperamentTraits, id: \.self) { trait in
                    ChipView(title: trait)
                }
            }
        }
    }
}

#if DEBUG
    #Preview("Cat Detail View"){
        NavigationStack {
            CatDetailView(breed: .preview)
        }
    }
#endif
