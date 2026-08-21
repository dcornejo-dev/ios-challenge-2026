import Combine
import Foundation
import Testing

@testable import NetworkLayer

struct MockNetworkingRequester: NetworkingRequesterType {
    var data: Data
    var error: NetworkError?

    func execute(request: NetworkingTargetType) -> AnyPublisher<Data, NetworkError> {
        if let error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(data)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

struct CapturingRequester: NetworkingRequesterType {
    let onExecute: (NetworkingTargetType) -> Void
    let data: Data

    func execute(request: NetworkingTargetType) -> AnyPublisher<Data, NetworkError> {
        onExecute(request)
        return Just(data)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

@Suite("CatBreedsService")
struct CatBreedsServiceTests {

    static let validBreedJSON = """
        [
            {
                "id": "abys",
                "name": "Abyssinian",
                "description": "Active and playful breed",
                "origin": "Egypt",
                "temperament": "Active, Energetic, Independent",
                "life_span": "14 - 15",
                "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
                "reference_image_id": "0XYvRd7oD"
            },
            {
                "id": "aege",
                "name": "Aegean",
                "description": "Native to Greece",
                "origin": "Greece",
                "temperament": "Affectionate, Social",
                "life_span": "9 - 12",
                "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
                "reference_image_id": null
            }
        ]
        """.data(using: .utf8)!

    private func collectFirst<T>(
        from publisher: AnyPublisher<T, NetworkError>
    ) -> T? {
        var result: T?
        var cancellables = Set<AnyCancellable>()
        publisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)
        return result
    }

    @Test("sends GET request to breeds path with page and limit")
    func requestPathAndParameters() throws {
        var capturedTarget: NetworkingTargetType?

        let requester = CapturingRequester(
            onExecute: { target in capturedTarget = target },
            data: Self.validBreedJSON
        )
        let service = CatBreedsService(requester: requester)

        _ = collectFirst(from: service.fetchBreeds(page: 2, limit: 15))

        let target = try #require(capturedTarget)
        #expect(target.requestPath == "breeds")
        #expect(target.requestMethod == .get)

        guard case .getBreeds(let page, let limit) = target as? CatBreedsTarget else {
            Issue.record("Expected CatBreedsTarget.getBreeds, got \(type(of: target))")
            return
        }
        #expect(page == 2)
        #expect(limit == 15)
    }

    @Test("decodes breed JSON with snake_case fields")
    func decodesBreeds() throws {
        let requester = MockNetworkingRequester(data: Self.validBreedJSON)
        let service = CatBreedsService(requester: requester)

        let breeds = try #require(collectFirst(from: service.fetchBreeds(page: 0, limit: 10)))
        #expect(breeds.count == 2)

        let abys = breeds[0]
        #expect(abys.id == "abys")
        #expect(abys.name == "Abyssinian")
        #expect(abys.description == "Active and playful breed")
        #expect(abys.origin == "Egypt")
        #expect(abys.temperament == "Active, Energetic, Independent")
        #expect(abys.lifeSpan == "14 - 15")
        #expect(abys.weight?.imperial == "7 - 10")
        #expect(abys.weight?.metric == "3 - 5")
        #expect(abys.referenceImageId == "0XYvRd7oD")
    }

    @Test("handles null reference_image_id gracefully")
    func nullOptionalFields() throws {
        let requester = MockNetworkingRequester(data: Self.validBreedJSON)
        let service = CatBreedsService(requester: requester)

        let breeds = try #require(collectFirst(from: service.fetchBreeds(page: 0, limit: 10)))
        let aegean = breeds[1]
        #expect(aegean.id == "aege")
        #expect(aegean.name == "Aegean")
        #expect(aegean.referenceImageId == nil)
    }

    @Test("decodes breeds when description, temperament, life_span, weight are null")
    func nullDetailFields() throws {
        let sparseJSON = """
            [
                {
                    "id": "spr",
                    "name": "Sparse Breed",
                    "description": null,
                    "origin": null,
                    "temperament": null,
                    "life_span": null,
                    "weight": null,
                    "reference_image_id": null
                }
            ]
            """.data(using: .utf8)!
        let requester = MockNetworkingRequester(data: sparseJSON)
        let service = CatBreedsService(requester: requester)

        let breeds = try #require(collectFirst(from: service.fetchBreeds(page: 0, limit: 10)))
        #expect(breeds.count == 1)
        let sparse = breeds[0]
        #expect(sparse.description == nil)
        #expect(sparse.temperament == nil)
        #expect(sparse.lifeSpan == nil)
        #expect(sparse.weight == nil)
        #expect(sparse.temperamentTraits.isEmpty)
    }
}
