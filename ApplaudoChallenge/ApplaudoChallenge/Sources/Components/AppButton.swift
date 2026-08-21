import SwiftUI

struct AppButton: View {

    enum Style {
        case primary
        case secondary
        case destructive
    }

    enum Shape {
        case rounded
        case pill
    }

    let title: String
    var style: Style = .primary
    var shape: Shape = .rounded
    var isEnabled: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard isEnabled, !isLoading else { return }
            action()
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    Text(title)
                        .font(AppTheme.Fonts.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: style == .secondary ? 2 : 0)
            )
        }
        .opacity(isEnabled ? 1.0 : 0.5)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: AppTheme.Animation.standard), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .disabled(!isEnabled)
    }

    // MARK: - Style Helpers

    private var cornerRadius: CGFloat {
        switch shape {
        case .rounded: return AppTheme.CornerRadius.medium
        case .pill: return AppTheme.CornerRadius.pill
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return AppTheme.Colors.primary
        case .secondary: return .clear
        case .destructive: return AppTheme.Colors.error
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return AppTheme.Colors.primary
        case .destructive: return .white
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return AppTheme.Colors.primary
        case .destructive: return .clear
        }
    }
}

// MARK: - Preview

#Preview("App Buttons") {
    VStack(spacing: AppTheme.Spacing.md) {
        AppButton(title: "Primary Button", style: .primary) {}
        AppButton(title: "Secondary Button", style: .secondary) {}
        AppButton(title: "Destructive Button", style: .destructive) {}
        AppButton(title: "Disabled Button", style: .primary, isEnabled: false) {}
        AppButton(title: "Loading...", style: .primary, isLoading: true) {}
        AppButton(title: "Pill Button", style: .primary, shape: .pill) {}
    }
    .padding(AppTheme.Spacing.lg)
}
