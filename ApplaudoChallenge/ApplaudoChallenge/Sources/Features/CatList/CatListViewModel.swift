import Foundation
import Combine
import NetworkLayer

final class CatListViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[CatBreed]> = .idle

    private let service: CatBreedsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private let pageSize = 10

    init(service: CatBreedsServiceProtocol = CatBreedsService()) {
        self.service = service
    }

    func fetchBreeds() {
        state = .loading

        service.fetchBreeds(page: currentPage, limit: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(
                        error.errorDescription ?? "An unexpected error occurred. Please try again."
                    )
                }
            } receiveValue: { [weak self] breeds in
                self?.state = .loaded(breeds)
            }
            .store(in: &cancellables)
    }
}
