import Combine
import Foundation
import NetworkLayer
import Testing

@testable import ApplaudoChallenge

final class MockCatBreedsService: CatBreedsServiceType {
    private let resultProvider: (Int) -> Result<[CatBreed], NetworkError>
    private(set) var requestedPages: [Int] = []

    init(result: Result<[CatBreed], NetworkError>) {
        self.resultProvider = { _ in result }
    }

    init(results: [Result<[CatBreed], NetworkError>]) {
        var iterator = results.makeIterator()
        self.resultProvider = { _ in iterator.next() ?? .success([]) }
    }

    init(pages: [Int: Result<[CatBreed], NetworkError>]) {
        self.resultProvider = { page in pages[page] ?? .success([]) }
    }

    init(resultProvider: @escaping (Int) -> Result<[CatBreed], NetworkError>) {
        self.resultProvider = resultProvider
    }

    func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError> {
        requestedPages.append(page)
        return resultProvider(page).publisher.eraseToAnyPublisher()
    }
}

@Suite("CatListViewModel", .serialized)
struct CatListViewModelTests {

    private static let testSleepDuration = Duration.milliseconds(300)

    static func makeBreeds(count: Int, prefix: String) -> [CatBreed] {
        (0..<count).compactMap { index in
            let json = """
                {
                    "id": "\(prefix)-\(index)",
                    "name": "\(prefix) \(index)",
                    "description": "Test breed",
                    "origin": "Testland",
                    "temperament": "Curious",
                    "life_span": "10 - 12",
                    "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
                    "reference_image_id": "ref-\(prefix)-\(index)"
                }
                """.data(using: .utf8)!
            return try? JSONDecoder().decode(CatBreed.self, from: json)
        }
    }

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

    // MARK: - Pagination

    @Test("loadNextPage appends the second page to the loaded list")
    func loadNextPageAppends() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let secondPage = Self.makeBreeds(count: 10, prefix: "p1")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .success(secondPage),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(loadedValue(viewModel.state)?.count == 10)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 20)
        #expect(breeds.first?.id == "p0-0")
        #expect(breeds.last?.id == "p1-9")
        #expect(service.requestedPages == [0, 1])
    }

    @Test("loadNextPage does not fire a second request while one is in flight")
    func loadNextPageDedupesInFlight() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let secondPage = Self.makeBreeds(count: 10, prefix: "p1")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .success(secondPage),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        viewModel.loadNextPage()
        viewModel.loadNextPage()
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1])
    }

    @Test("loadNextPage stops firing once a short page marks end-of-data")
    func loadNextPageStopsAtEndOfData() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let shortSecondPage = Self.makeBreeds(count: 3, prefix: "p1")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .success(shortSecondPage),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(loadedValue(viewModel.state)?.count == 13)

        viewModel.loadNextPage()
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1])
    }

    @Test("fetchBreeds resets pagination state so it re-requests page 0")
    func fetchBreedsResetsPagination() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let secondPage = Self.makeBreeds(count: 10, prefix: "p1")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .success(secondPage),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(service.requestedPages == [0, 1])

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1, 0])
        #expect(loadedValue(viewModel.state)?.count == 10)
        #expect(viewModel.isLoadingMore == false)
        #expect(viewModel.paginationError == nil)
    }

    // MARK: - Pagination error path

    @Test("loadNextPage failure preserves loaded breeds and sets paginationError")
    func loadNextPageFailurePreservesLoadedBreeds() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .failure(.serverError(statusCode: 500, data: Data())),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(loadedValue(viewModel.state)?.count == 10)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 10)
        #expect(breeds.first?.id == "p0-0")
        #expect(viewModel.isLoadingMore == false)
        let message = try #require(viewModel.paginationError)
        #expect(!message.isEmpty)
    }

    @Test("loadNextPage after failure is a no-op until Retry clears the error")
    func loadNextPageIsNoOpAfterFailure() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let service = MockCatBreedsService(pages: [
            0: .success(firstPage),
            1: .failure(.serverError(statusCode: 500, data: Data())),
        ])
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(viewModel.paginationError != nil)

        viewModel.loadNextPage()
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1])
    }

    @Test("Retry re-requests the same page that failed")
    func retryReRequestsSamePage() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let secondPage = Self.makeBreeds(count: 10, prefix: "p1")
        var page1Result: Result<[CatBreed], NetworkError> = .failure(
            .serverError(statusCode: 500, data: Data())
        )
        let service = MockCatBreedsService(resultProvider: { page in
            if page == 0 { return .success(firstPage) }
            if page == 1 { return page1Result }
            return .success([])
        })
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(viewModel.paginationError != nil)

        page1Result = .success(secondPage)
        viewModel.retryLoadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1, 1])
        #expect(viewModel.paginationError == nil)
        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 20)
        #expect(breeds.last?.id == "p1-9")
    }

    @Test("Pagination resumes normally after a successful Retry")
    func paginationResumesAfterSuccessfulRetry() async throws {
        let firstPage = Self.makeBreeds(count: 10, prefix: "p0")
        let secondPage = Self.makeBreeds(count: 10, prefix: "p1")
        let thirdPage = Self.makeBreeds(count: 10, prefix: "p2")
        var page1Result: Result<[CatBreed], NetworkError> = .failure(
            .serverError(statusCode: 500, data: Data())
        )
        let service = MockCatBreedsService(resultProvider: { page in
            switch page {
            case 0: return .success(firstPage)
            case 1: return page1Result
            case 2: return .success(thirdPage)
            default: return .success([])
            }
        })
        let viewModel = CatListViewModel(service: service)

        viewModel.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(viewModel.paginationError != nil)

        page1Result = .success(secondPage)
        viewModel.retryLoadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)
        try #require(loadedValue(viewModel.state)?.count == 20)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.testSleepDuration)

        #expect(service.requestedPages == [0, 1, 1, 2])
        let breeds = try #require(loadedValue(viewModel.state))
        #expect(breeds.count == 30)
        #expect(breeds.last?.id == "p2-9")
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
