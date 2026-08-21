import Combine
import Foundation
import NetworkLayer
import Testing

@testable import ApplaudoChallenge

struct MockCatBreedsService: CatBreedsServiceType {
    var resultProvider: () -> Result<[CatBreed], NetworkError>

    init(result: Result<[CatBreed], NetworkError>) {
        self.resultProvider = { result }
    }

    init(results: [Result<[CatBreed], NetworkError>]) {
        var iterator = results.makeIterator()
        self.resultProvider = { iterator.next() ?? .success([]) }
    }

    func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError> {
        resultProvider().publisher.eraseToAnyPublisher()
    }
}

@Suite("CatListViewModel")
struct CatListViewModelTests {

    private static let testSleepDuration = Duration.milliseconds(100)

    static let sampleBreeds: [CatBreed] = {
        let json = """
            [
                {
                    "id": "abys",
                    "name": "Abyssinian",
                    "description": "Active and playful",
                    "origin": "Egypt",
                    "temperament": "Active, Energetic",
                    "life_span": "14 - 15",
                    "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
                    "reference_image_id": "0XYvRd7oD"
                }
            ]
            """.data(using: .utf8)!
        return (try? JSONDecoder().decode([CatBreed].self, from: json)) ?? []
    }()

    @Test("starts in idle state")
    func initialState() throws {
        let service = MockCatBreedsService(result: .success([]))
        let viewModel = CatListViewModel(service: service)

        try #require(isIdle(viewModel.state))
    }

    @Test("transitions idle → loading → loaded with breeds")
    func fetchBreedsSuccess() async throws {
        let service = MockCatBreedsService(result: .success(Self.sampleBreeds))
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try #require(isLoading(viewModel.state))

        try await Task.sleep(for: Self.testSleepDuration)

        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 1)
        #expect(breeds.first?.name == "Abyssinian")
    }

    @Test("transitions idle → loading → loaded with empty array")
    func fetchBreedsEmpty() async throws {
        let service = MockCatBreedsService(result: .success([]))
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try #require(isLoading(viewModel.state))

        try await Task.sleep(for: Self.testSleepDuration)

        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.isEmpty)
    }

    @Test("transitions idle → loading → error with user-readable message")
    func fetchBreedsError() async throws {
        let service = MockCatBreedsService(
            result: .failure(.serverError(statusCode: 500, data: Data()))
        )
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try #require(isLoading(viewModel.state))

        try await Task.sleep(for: Self.testSleepDuration)

        let message = try #require(errorMessage(viewModel.state))
        #expect(!message.isEmpty)
    }

    @Test("calling fetchBreeds again after error resets to loading then resolves")
    func retryAfterError() async throws {
        let service = MockCatBreedsService(results: [
            .failure(.unknown(underlying: NSError(domain: "test", code: -1))),
            .success(Self.sampleBreeds),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(errorMessage(viewModel.state) != nil)

        viewModel.fetchBreeds()
        try #require(isLoading(viewModel.state))

        try await Task.sleep(for: Self.testSleepDuration)

        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 1)
    }

    // MARK: - ViewState helpers

    private func isIdle(_ state: ViewState<[CatBreed]>) -> Bool {
        if case .idle = state { return true }
        return false
    }

    private func isLoading(_ state: ViewState<[CatBreed]>) -> Bool {
        if case .loading = state { return true }
        return false
    }

    private func loadedValue(_ state: ViewState<[CatBreed]>) -> [CatBreed]? {
        if case .loaded(let value) = state { return value }
        return nil
    }

    private func errorMessage(_ state: ViewState<[CatBreed]>) -> String? {
        if case .error(let msg) = state { return msg }
        return nil
    }
}
