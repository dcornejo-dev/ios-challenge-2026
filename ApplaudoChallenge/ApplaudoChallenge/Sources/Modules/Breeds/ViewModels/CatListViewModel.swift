import Combine
import Foundation
import NetworkLayer

final class CatListViewModel: ObservableObject {
    // MARK: - Properties
    private let service: CatBreedsServiceType
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private let pageSize = 10

    @Published private(set) var state: ViewState<[CatBreed]> = .idle

    // MARK: - Initializers
    init(service: CatBreedsServiceType = CatBreedsService()) {
        self.service = service
    }

    // MARK: - Public Methods
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
