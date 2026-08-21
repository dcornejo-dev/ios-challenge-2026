import SwiftUI

struct ChipView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(AppTheme.Fonts.caption)
            .foregroundColor(AppTheme.Colors.primary)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.primary.opacity(0.1))
            )
    }
}

// MARK: - Preview

#Preview("Chip View") {
    HStack(spacing: AppTheme.Spacing.sm) {
        ChipView(title: "Playful")
        ChipView(title: "Affectionate")
        ChipView(title: "Intelligent")
    }
    .padding(AppTheme.Spacing.lg)
}
