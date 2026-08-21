//
//  NetworkingRequester.swift
//  ApplaudoChallenge
//
//  Created by Christian Rivera on 25/3/26.
//

import Combine
import Foundation
import Moya

// MARK: - Network Error
/// Lightweight domain error type that wraps common networking failures.
/// Candidates can extend this enum with additional cases as needed.
public enum NetworkError: Error, LocalizedError {
    /// The server returned an unexpected status code.
    case serverError(statusCode: Int, data: Data)
    /// The response data could not be decoded into the expected type.
    case decodingFailed(underlying: Error)
    /// A generic/unknown failure.
    case unknown(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .serverError(let code, _):
            return "Server returned status code \(code)."
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Networking Requester Type
/// Core networking abstraction. Any type conforming to this protocol can execute API requests.
/// Implement `execute` to drive the full request lifecycle using the provided `NetworkingTargetType`.
protocol NetworkingRequesterType {
    /// Executes a network request and returns a raw-data publisher.
    /// - Parameter request: The endpoint descriptor conforming to `NetworkingTargetType`.
    func execute(request: NetworkingTargetType) -> AnyPublisher<Data, NetworkError>
}

// MARK: - Networking Requester
/// Concrete implementation of `NetworkingRequesterType` backed by a Moya `MoyaProvider<MultiTarget>`.
struct NetworkingRequester: NetworkingRequesterType {
    // MARK: - Properties
    private let provider: MoyaProvider<MultiTarget>

    // MARK: - Initializer
    init(
        provider: MoyaProvider<MultiTarget>
    ) {
        self.provider = provider
    }

    func execute(request: NetworkingTargetType) -> AnyPublisher<Data, NetworkError> {
        var task: Moya.Cancellable?
        let provider = provider  // Captured locally to avoid reference issues inside the closure.

        // Wrap the callback-based Moya API in a Combine Future so callers get a single-value publisher.
        return Deferred {
            Future { seal in
                // Store the cancellable so it can be cancelled later if the subscriber disposes.
                task = provider.request(MultiTarget(request)) { result in
                    switch result {
                    case .success(let response):
                        let statusCode = response.statusCode

                        // Reject any response outside the 2XX range as a server error.
                        guard (200...299).contains(statusCode) else {
                            seal(.failure(.serverError(statusCode: statusCode, data: response.data)))
                            return
                        }

                        seal(.success(response.data))
                    case .failure(let error):
                        // Moya-level failures (e.g. no connection) map to the generic domain error.
                        seal(.failure(.unknown(underlying: error)))
                    }
                }
            }
        }
        // Propagate Combine cancellation back to the in-flight Moya task.
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

// MARK: - Default Implementation
/// Convenience overload that decodes the raw response into a `Decodable` type.
/// Reuses the raw-data `execute` and layers Combine's `decode` operator on top.
extension NetworkingRequesterType {
    /// - Parameters:
    ///   - request: The endpoint descriptor.
    ///   - decoder: `JSONDecoder` to use; defaults to a standard instance.
    func execute<T: Decodable>(
        request: NetworkingTargetType,
        using decoder: JSONDecoder = .init()
    ) -> AnyPublisher<T, NetworkError> {
        execute(request: request)  // Reuse the raw-data publisher.
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                // Preserve any NetworkError that passed through; wrap all others as decoding failures.
                if let networkError = error as? NetworkError {
                    return networkError
                }

                return .decodingFailed(underlying: error)
            }
            .eraseToAnyPublisher()
    }
}
