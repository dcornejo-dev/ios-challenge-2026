import SwiftUI

struct PaginationFooter: View {
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void

    var body: some View {
        Group {
            if let errorMessage {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(errorMessage)
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                    Spacer(minLength: AppTheme.Spacing.sm)
                    Button("Retry", action: onRetry)
                        .font(AppTheme.Fonts.headline)
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
            } else {
                EmptyView()
            }
        }
    }
}
