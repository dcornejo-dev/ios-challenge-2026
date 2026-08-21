import SwiftData
import SwiftUI

@main
struct ApplaudoChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: RegisteredCat.self)
    }
}
