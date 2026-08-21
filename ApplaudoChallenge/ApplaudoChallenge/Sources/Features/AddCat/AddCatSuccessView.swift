import SwiftUI
import UIKit

struct AddCatSuccessView: View {
    let catName: String
    let onDone: () -> Void

    private static let autoDismissDelay: Duration = .milliseconds(2500)

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 96))
                .foregroundColor(AppTheme.Colors.success)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Cat Registered")
                    .font(AppTheme.Fonts.largeTitle)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("\(catName) is now in My Cats.")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            AppButton(title: "Done", action: onDone)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
        .task {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            try? await Task.sleep(for: Self.autoDismissDelay)
            onDone()
        }
    }
}

#Preview {
    AddCatSuccessView(catName: "Whiskers", onDone: {})
}
