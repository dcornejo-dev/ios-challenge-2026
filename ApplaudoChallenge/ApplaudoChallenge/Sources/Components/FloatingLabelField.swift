import SwiftUI

struct FloatingLabelField<Content: View>: View {

    private enum Mode {
        case singleLine
        case multiline(maxChars: Int)
        case wrapping
    }

    private static var helperSlotHeight: CGFloat { 18 }
    private static var floatingLabelYOffset: CGFloat { -14 }

    let label: String
    let helperText: String?
    let errorMessage: String?

    private let mode: Mode
    private let text: Binding<String>
    private let keyboardType: UIKeyboardType
    private let contentType: UITextContentType?
    private let wrappedContent: Content

    @FocusState private var isFocused: Bool

    private var hasError: Bool { errorMessage != nil }

    private var isPopulated: Bool {
        switch mode {
        case .wrapping:
            return true
        case .singleLine, .multiline:
            return !text.wrappedValue.isEmpty
        }
    }

    private var shouldFloat: Bool { isFocused || isPopulated }

    private var borderColor: Color {
        if hasError { return AppTheme.Colors.error }
        if isFocused { return AppTheme.Colors.primary }
        return AppTheme.Colors.border
    }

    private var labelColor: Color {
        if hasError { return AppTheme.Colors.error }
        if shouldFloat { return AppTheme.Colors.textSecondary }
        return AppTheme.Colors.textPrimary
    }

    private var trailingHelperText: String? {
        if case .multiline(let maxChars) = mode {
            return "\(text.wrappedValue.count)/\(maxChars)"
        }
        return nil
    }

    init(
        label: String,
        text: Binding<String>,
        helperText: String? = nil,
        errorMessage: String? = nil,
        keyboardType: UIKeyboardType = .default,
        contentType: UITextContentType? = nil
    ) where Content == EmptyView {
        self.label = label
        self.text = text
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.mode = .singleLine
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.wrappedContent = EmptyView()
    }

    init(
        label: String,
        text: Binding<String>,
        maxChars: Int,
        helperText: String? = nil,
        errorMessage: String? = nil
    ) where Content == EmptyView {
        self.label = label
        self.text = text
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.mode = .multiline(maxChars: maxChars)
        self.keyboardType = .default
        self.contentType = nil
        self.wrappedContent = EmptyView()
    }

    init(
        label: String,
        helperText: String? = nil,
        errorMessage: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.text = .constant("")
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.mode = .wrapping
        self.keyboardType = .default
        self.contentType = nil
        self.wrappedContent = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            fieldSurface
            helperSlot
        }
    }

    private var fieldSurface: some View {
        ZStack(alignment: .topLeading) {
            fieldContent
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, shouldFloat ? AppTheme.Spacing.lg : AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                        .stroke(borderColor, lineWidth: 1)
                )

            Text(label)
                .font(shouldFloat ? AppTheme.Fonts.caption : AppTheme.Fonts.body)
                .foregroundColor(labelColor)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, shouldFloat ? AppTheme.Spacing.sm : AppTheme.Spacing.md)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.2), value: shouldFloat)
                .animation(.easeInOut(duration: 0.2), value: hasError)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switch mode {
            case .singleLine, .multiline:
                isFocused = true
            case .wrapping:
                break
            }
        }
    }

    @ViewBuilder
    private var fieldContent: some View {
        switch mode {
        case .singleLine:
            TextField("", text: text)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .focused($isFocused)

        case .multiline:
            TextField("", text: text, axis: .vertical)
                .lineLimit(3...6)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .focused($isFocused)

        case .wrapping:
            wrappedContent
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var helperSlot: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            if let errorMessage {
                Image(systemName: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.error)
                Text(errorMessage)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.error)
            } else if let helperText {
                Text(helperText)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer(minLength: 0)

            if let trailingHelperText {
                Text(trailingHelperText)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xs)
        .frame(height: Self.helperSlotHeight, alignment: .top)
    }
}

// MARK: - Preview

private struct FloatingLabelFieldPreview: View {

    @State private var emptyText: String = ""
    @State private var populatedText: String = "Whiskers"
    @State private var errorText: String = "!!"
    @State private var bio: String = "A curious cat that loves cardboard boxes."
    @State private var gender: String = "Female"
    @State private var coat: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                FloatingLabelField(
                    label: "Name",
                    text: $emptyText,
                    helperText: "As it appears on the pedigree"
                )

                FloatingLabelField(
                    label: "Name",
                    text: $populatedText
                )

                FloatingLabelField(
                    label: "Email",
                    text: $errorText,
                    errorMessage: "Enter a valid email address",
                    keyboardType: .emailAddress,
                    contentType: .emailAddress
                )

                FloatingLabelField(
                    label: "Bio",
                    text: $bio,
                    maxChars: 140
                )

                FloatingLabelField(label: "Gender") {
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(.segmented)
                }

                FloatingLabelField(label: "Coat color") {
                    Menu {
                        Button("Black") { coat = "Black" }
                        Button("White") { coat = "White" }
                        Button("Tabby") { coat = "Tabby" }
                    } label: {
                        HStack {
                            Text(coat ?? "Select a coat color")
                                .foregroundColor(
                                    coat == nil
                                        ? AppTheme.Colors.textSecondary
                                        : AppTheme.Colors.textPrimary
                                )
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .font(AppTheme.Fonts.body)
                    }
                }
            }
            .padding(AppTheme.Spacing.lg)
        }
    }
}

#Preview("Floating Label Field") {
    FloatingLabelFieldPreview()
}
