import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        TabView {
            NavigationStack {
                CatListView()
            }
            .tabItem {
                Label("Cats", systemImage: "cat")
            }

            NavigationStack {
                MyCatsView()
            }
            .tabItem {
                Label("My Cats", systemImage: "pawprint")
            }

            NavigationStack {
                AddCatStepperView()
            }
            .tabItem {
                Label("Add Cat", systemImage: "plus.circle")
            }
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview{
    ContentView()
}
