import Combine
import Foundation
import NetworkLayer
import SwiftData

final class AddCatViewModel: ObservableObject {
    // MARK: - Properties
    private let service: CatBreedsServiceType
    private var cancellables = Set<AnyCancellable>()

    static let totalSteps = 3
    static let stepTitles = ["Basic Info", "Details", "Review"]

    @Published var currentStep = 0
    @Published var name = ""
    @Published var breedName = ""
    @Published var breedId = ""
    @Published var age = ""
    @Published var shortDescription = ""
    @Published var color = ""
    @Published var gender: CatGender = .unknown
    @Published var photo: Data?
    @Published var breedsState: ViewState<[CatBreed]> = .idle
    @Published var step1Errors: [String: String] = [:]
    @Published var step2Errors: [String: String] = [:]
    @Published var isSaved = false

    // MARK: - Initializers
    init(service: CatBreedsServiceType = CatBreedsService()) {
        self.service = service
    }

    // MARK: - Public Methods
    func fetchBreeds() {
        breedsState = .loading

        service.fetchBreeds(page: 0, limit: 100)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.breedsState = .error(
                        error.errorDescription ?? "Failed to load breeds."
                    )
                }
            } receiveValue: { [weak self] breeds in
                self?.breedsState = .loaded(breeds)
            }
            .store(in: &cancellables)
    }

    func validateAndAdvance() -> Bool {
        switch currentStep {
        case 0:
            return validateStep1()
        case 1:
            return validateStep2()
        default:
            return false
        }
    }

    func goBack() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func save(context: ModelContext) {
        guard let ageInt = Int(age) else { return }

        let cat = RegisteredCat(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            breedName: breedName,
            breedId: breedId,
            age: ageInt,
            shortDescription: shortDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            gender: gender,
            photo: photo
        )
        context.insert(cat)
        isSaved = true
    }

    func reset() {
        currentStep = 0
        name = ""
        breedName = ""
        breedId = ""
        age = ""
        shortDescription = ""
        color = ""
        gender = .unknown
        photo = nil
        step1Errors = [:]
        step2Errors = [:]
        isSaved = false
    }

    func clearStep1Error(for field: String) {
        step1Errors.removeValue(forKey: field)
    }

    func clearStep2Error(for field: String) {
        step2Errors.removeValue(forKey: field)
    }

    // MARK: - Private Methods
    private func validateStep1() -> Bool {
        step1Errors = [:]

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.count < 2 {
            step1Errors["name"] = "Name must be at least 2 characters"
        }
        if breedName.isEmpty {
            step1Errors["breed"] = "Please select a breed"
        }

        if step1Errors.isEmpty {
            currentStep = 1
            return true
        }
        return false
    }

    private func validateStep2() -> Bool {
        step2Errors = [:]

        if let ageInt = Int(age), ageInt >= 1, ageInt <= 30 {
            // valid
        } else {
            step2Errors["age"] = "Age must be a number between 1 and 30"
        }

        let trimmedDesc = shortDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDesc.count < 10 {
            step2Errors["shortDescription"] = "Description must be at least 10 characters"
        }

        if step2Errors.isEmpty {
            currentStep = 2
            return true
        }
        return false
    }
}
