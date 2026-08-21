import Foundation
import SwiftData
import Testing

@testable import ApplaudoChallenge

@Suite("MyCatsViewModel")
struct MyCatsViewModelTests {

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: RegisteredCat.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func makeCat(
        name: String,
        createdAt: Date = Date()
    ) -> RegisteredCat {
        RegisteredCat(
            name: name,
            breedName: "Bengal",
            breedId: "beng",
            age: 3,
            shortDescription: "A friendly cat",
            color: "orange",
            gender: .male,
            createdAt: createdAt
        )
    }

    // MARK: - Fetch

    @Test("returns empty array when no cats exist")
    func fetchEmpty() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = MyCatsViewModel()

        vm.fetchCats(context: context)

        #expect(vm.cats.isEmpty)
    }

    @Test("returns cats sorted newest first")
    func fetchSortedNewestFirst() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let oldest = makeCat(name: "Oldest", createdAt: Date(timeIntervalSince1970: 1000))
        let middle = makeCat(name: "Middle", createdAt: Date(timeIntervalSince1970: 2000))
        let newest = makeCat(name: "Newest", createdAt: Date(timeIntervalSince1970: 3000))

        context.insert(oldest)
        context.insert(middle)
        context.insert(newest)

        let vm = MyCatsViewModel()
        vm.fetchCats(context: context)

        #expect(vm.cats.count == 3)
        #expect(vm.cats[0].name == "Newest")
        #expect(vm.cats[1].name == "Middle")
        #expect(vm.cats[2].name == "Oldest")
    }

    @Test("re-fetch picks up newly inserted cat")
    func reFetchAfterInsert() throws {
        let container = try makeContainer()
        let context = ModelContext(container)
        let vm = MyCatsViewModel()

        vm.fetchCats(context: context)
        #expect(vm.cats.isEmpty)

        let cat = makeCat(name: "Whiskers")
        context.insert(cat)

        vm.fetchCats(context: context)
        #expect(vm.cats.count == 1)
        #expect(vm.cats[0].name == "Whiskers")
    }
}
