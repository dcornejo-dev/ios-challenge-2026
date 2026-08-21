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
        }
        .tint(AppTheme.Colors.primary)
    }
}

#Preview{
    ContentView()
}
