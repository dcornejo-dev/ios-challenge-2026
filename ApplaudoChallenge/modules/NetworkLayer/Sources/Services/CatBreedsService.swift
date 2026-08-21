import Foundation
import Combine
import Moya

public protocol CatBreedsServiceType {
    func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError>
}

public struct CatBreedsService: CatBreedsServiceType {
    // MARK: - Properties
    private let requester: NetworkingRequesterType

    // MARK: - Initializers
    public init() {
        self.requester = NetworkingRequester(provider: .networkingProvider())
    }

    init(requester: NetworkingRequesterType) {
        self.requester = requester
    }

    // MARK: - Public Methods
    public func fetchBreeds(page: Int, limit: Int) -> AnyPublisher<[CatBreed], NetworkError> {
        requester.execute(
            request: CatBreedsTarget.getBreeds(page: page, limit: limit)
        )
    }
}
