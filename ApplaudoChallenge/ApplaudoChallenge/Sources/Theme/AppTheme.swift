import SwiftUI

enum AppTheme {

    // MARK: - Colors

    enum Colors {
        static let primary = Color(light: Color(hex: "FF4040"), dark: Color(hex: "FF6B6B"))
        static let secondary = Color(light: Color(hex: "4A4A4A"), dark: Color(hex: "B0B0B0"))
        static let background = Color(light: .white, dark: .black)
        static let surface = Color(light: Color(hex: "F5F5F5"), dark: Color(hex: "1C1C1E"))
        static let textPrimary = Color(light: Color(hex: "1A1A1A"), dark: .white)
        static let textSecondary = Color(light: Color(hex: "8E8E93"), dark: Color(hex: "8E8E93"))
        static let error = Color(light: Color(hex: "D32F2F"), dark: Color(hex: "EF5350"))
        static let success = Color(light: Color(hex: "2E7D32"), dark: Color(hex: "66BB6A"))
        static let border = Color(light: Color(hex: "E0E0E0"), dark: Color(hex: "3A3A3C"))
    }

    // MARK: - Fonts

    enum Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 22, weight: .bold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}

// MARK: - Color Helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r: Double
        let g: Double
        let b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1
            g = 1
            b = 1
        }
        self.init(red: r, green: g, blue: b)
    }

    init(light: Color, dark: Color) {
        self.init(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            })
    }
}
