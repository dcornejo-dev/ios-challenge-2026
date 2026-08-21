import Foundation
import SwiftData

final class MyCatsViewModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var cats: [RegisteredCat] = []

    // MARK: - Public Methods
    func fetchCats(context: ModelContext) {
        let descriptor = FetchDescriptor<RegisteredCat>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        cats = (try? context.fetch(descriptor)) ?? []
    }
}
