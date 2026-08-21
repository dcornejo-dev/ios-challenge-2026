import SwiftUI

public struct ContentView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CatListView()
            }
            .tabItem {
                Label("Cats", systemImage: "cat")
            }
            .tag(0)

            NavigationStack {
                MyCatsView()
            }
            .tabItem {
                Label("My Cats", systemImage: "pawprint")
            }
            .tag(1)

            NavigationStack {
                AddCatStepperView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Add Cat", systemImage: "plus.circle")
            }
            .tag(2)
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview{
    ContentView()
}
