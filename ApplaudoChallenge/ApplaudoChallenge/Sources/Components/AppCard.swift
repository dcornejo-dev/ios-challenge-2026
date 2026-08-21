import SwiftUI

struct AppCard: View {

    let title: String
    var subtitle: String = ""
    var imageSystemName: String = "photo"
    var imageData: Data? = nil
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            iconView

            // Text Content
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

            Spacer()

            // Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private var iconView: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Image(systemName: imageSystemName)
                .font(.title2)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 50, height: 50)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .clipShape(Circle())
        }
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
