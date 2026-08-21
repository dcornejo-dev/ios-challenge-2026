import SwiftUI

struct StepDashesIndicator: View {

    private static var dashWidth: CGFloat { 24 }
    private static var dashHeight: CGFloat { 3 }
    private static var dashCornerRadius: CGFloat { 1.5 }
    private static var dashSpacing: CGFloat { 6 }
    private static var inactiveColor: Color { Color.gray.opacity(0.25) }

    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: Self.dashSpacing) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: Self.dashCornerRadius)
                    .fill(color(for: index))
                    .frame(width: Self.dashWidth, height: Self.dashHeight)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    private func color(for index: Int) -> Color {
        index == currentStep ? AppTheme.Colors.textPrimary : Self.inactiveColor
    }
}

// MARK: - Preview

#Preview("Step Dashes Indicator") {
    VStack(spacing: AppTheme.Spacing.lg) {
        StepDashesIndicator(totalSteps: 3, currentStep: 0)
        StepDashesIndicator(totalSteps: 3, currentStep: 1)
        StepDashesIndicator(totalSteps: 3, currentStep: 2)
    }
    .padding(AppTheme.Spacing.lg)
}
