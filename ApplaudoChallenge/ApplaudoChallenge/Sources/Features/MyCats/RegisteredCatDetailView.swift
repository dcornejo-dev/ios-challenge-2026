import SwiftUI

struct RegisteredCatDetailView: View {
    let cat: RegisteredCat

    var body: some View {
        Text(cat.name)
            .navigationTitle(cat.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}
