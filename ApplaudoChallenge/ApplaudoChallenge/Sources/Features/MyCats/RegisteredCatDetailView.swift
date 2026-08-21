import SwiftUI

struct RegisteredCatDetailView: View {
    let cat: RegisteredCat

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                heroImage
                detailSections
            }
        }
        .navigationTitle(cat.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroImage: some View {
        Color.clear
            .aspectRatio(4 / 3, contentMode: .fit)
            .overlay {
                if let photoData = cat.photo, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    imagePlaceholder
                }
            }
            .clipped()
    }

    private var imagePlaceholder: some View {
        ZStack {
            AppTheme.Colors.surface
            Image(systemName: "pawprint")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }

    private var detailSections: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            infoSection
            textSection(title: "Description", systemImage: "text.alignleft", text: cat.shortDescription)
            registeredDateFooter
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.lg)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(title: "Info", systemImage: "info.circle")
            infoRow(label: "Breed", value: cat.breedName)
            infoRow(label: "Age", value: "\(cat.age) \(cat.age == 1 ? "year" : "years")")
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }

    private func textSection(title: String, systemImage: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            SectionHeader(title: title, systemImage: systemImage)
            Text(text)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }

    private var registeredDateFooter: some View {
        Text("Registered on \(cat.createdAt.formatted(date: .abbreviated, time: .omitted))")
            .font(AppTheme.Fonts.caption)
            .foregroundColor(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity)
    }
}
