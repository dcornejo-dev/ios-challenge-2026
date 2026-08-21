import Foundation
import Combine
import Moya

public protocol CatBreedsServiceProtocol {
    func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError>
}

public struct CatBreedsService: CatBreedsServiceProtocol {
    private let requester: NetworkingRequesterType

    public init() {
        self.requester = NetworkingRequester(provider: .networkingProvider())
    }

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    public func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError> {
        requester.execute(
            request: CatBreedsTarget.getBreeds(page: page, limit: limit)
        )
    }
}
