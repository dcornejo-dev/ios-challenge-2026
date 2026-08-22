import Combine
import Foundation
import NetworkLayer

final class CatListViewModel: ObservableObject {
    // MARK: - Properties
    private let service: CatBreedsServiceType
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private let pageSize = 10
    private var hasMorePages = true

    @Published private(set) var state: ViewState<[CatBreed]> = .idle
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var paginationError: String?

    // MARK: - Initializers
    init(service: CatBreedsServiceType = CatBreedsService()) {
        self.service = service
    }

    // MARK: - Public Methods
    func fetchBreeds() {
        currentPage = 0
        hasMorePages = true
        isLoadingMore = false
        paginationError = nil
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
                guard let self else { return }
                self.hasMorePages = (breeds.count == self.pageSize)
                self.state = .loaded(breeds)
            }
            .store(in: &cancellables)
    }

    func retryLoadNextPage() {
        paginationError = nil
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoadingMore, hasMorePages, paginationError == nil else { return }
        guard case .loaded(let existing) = state else { return }

        currentPage += 1
        isLoadingMore = true
        let requestedPage = currentPage

        service.fetchBreeds(page: requestedPage, limit: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoadingMore = false
                if case .failure(let error) = completion {
                    self.currentPage -= 1
                    self.paginationError = error.errorDescription
                        ?? "Failed to load more. Please try again."
                }
            } receiveValue: { [weak self] newBreeds in
                guard let self else { return }
                self.hasMorePages = (newBreeds.count == self.pageSize)
                self.state = .loaded(existing + newBreeds)
            }
            .store(in: &cancellables)
    }
}
