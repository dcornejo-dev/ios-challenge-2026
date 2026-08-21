import SwiftUI

struct AppCard: View {

    let title: String
    var subtitle: String = ""
    var imageSystemName: String = "photo"
    var imageData: Data? = nil
    var imageURL: URL? = nil
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            leadingVisual
                .frame(width: 100)
                .clipped()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Fonts.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.trailing, AppTheme.Spacing.md)
            }
        }
        .frame(minHeight: 120)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var leadingVisual: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let imageURL {
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

    private var imagePlaceholder: some View {
        Image(systemName: imageSystemName)
            .font(.title2)
            .foregroundColor(AppTheme.Colors.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.primary.opacity(0.1))
    }
}

// MARK: - Preview

#Preview("App Card"){
    VStack(spacing: AppTheme.Spacing.md) {
        AppCard(
            title: "Persian",
            subtitle: "Calm and affectionate breed",
            imageSystemName: "cat"
        )

        AppCard(
            title: "Siamese",
            subtitle: "Vocal and social breed",
            imageSystemName: "cat.fill"
        )

        AppCard(
            title: "No Arrow",
            subtitle: "Card without chevron",
            imageSystemName: "pawprint.fill",
            showChevron: false
        )
    }
    .padding(AppTheme.Spacing.lg)
}
