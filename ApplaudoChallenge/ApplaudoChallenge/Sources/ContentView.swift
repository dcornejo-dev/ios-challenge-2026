import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        TabView {
            // MARK: - Tab 1: Cat List
            NavigationStack {
                CatListView()
            }
            .tabItem {
                Label("Cats", systemImage: "cat")
            }

            // MARK: - Tab 2: Add Cat
            // TODO: Replace placeholder with your AddCatStepperView
            NavigationStack {
                Text("Add New Cat")
                    .font(AppTheme.Fonts.title)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .navigationTitle("Add Cat")
            }
            .tabItem {
                Label("Add Cat", systemImage: "plus.circle")
            }
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
