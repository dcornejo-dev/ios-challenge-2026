import SwiftUI

struct SectionHeader: View {

    enum Style {
        case standard
        case prominent
    }

    let title: String
    var subtitle: String?
    var systemImage: String = "square.grid.2x2"
    var style: Style = .standard

    var body: some View {
        switch style {
        case .standard:
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(AppTheme.Colors.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Fonts.headline)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                Spacer()
            }

        case .prominent:
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Fonts.title)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.secondary)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview("Section Header") {
    VStack(spacing: AppTheme.Spacing.lg) {
        SectionHeader(
            title: "Breed Information",
            subtitle: "Fill in the basic details",
            systemImage: "info.circle"
        )

        SectionHeader(
            title: "Appearance",
            systemImage: "paintpalette"
        )

        SectionHeader(
            title: "Cat Details",
            subtitle: "Tell us about your cat",
            style: .prominent
        )

        SectionHeader(
            title: "Prominent No Subtitle",
            style: .prominent
        )
    }
    .padding(AppTheme.Spacing.lg)
}
