import Combine
import Foundation
import NetworkLayer
import SwiftData
import Testing

@testable import ApplaudoChallenge

@Suite("AddCatViewModel")
struct AddCatViewModelTests {

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
                },
                {
                    "id": "beng",
                    "name": "Bengal",
                    "description": "Wild-looking domestic cat",
                    "origin": "United States",
                    "temperament": "Alert, Agile",
                    "life_span": "12 - 15",
                    "weight": { "imperial": "6 - 12", "metric": "3 - 5" },
                    "reference_image_id": null
                }
            ]
            """.data(using: .utf8)!
        return (try? JSONDecoder().decode([CatBreed].self, from: json)) ?? []
    }()

    // MARK: - Step 1 Validation

    @Test("step 1 fails with empty name")
    func step1EmptyName() {
        let vm = makeViewModel()
        vm.breedName = "Bengal"
        vm.breedId = "beng"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.currentStep == 0)
        #expect(vm.step1Errors["name"] != nil)
    }

    @Test("step 1 fails with name shorter than 2 characters")
    func step1ShortName() {
        let vm = makeViewModel()
        vm.name = "A"
        vm.breedName = "Bengal"
        vm.breedId = "beng"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step1Errors["name"] != nil)
    }

    @Test("step 1 fails with whitespace-only name")
    func step1WhitespaceName() {
        let vm = makeViewModel()
        vm.name = "   "
        vm.breedName = "Bengal"
        vm.breedId = "beng"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step1Errors["name"] != nil)
    }

    @Test("step 1 fails with no breed selected")
    func step1NoBreed() {
        let vm = makeViewModel()
        vm.name = "Whiskers"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step1Errors["breed"] != nil)
    }

    @Test("step 1 shows errors for both fields when both invalid")
    func step1BothFieldsInvalid() {
        let vm = makeViewModel()

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step1Errors["name"] != nil)
        #expect(vm.step1Errors["breed"] != nil)
    }

    @Test("step 1 advances with valid name (exactly 2 chars) and breed")
    func step1ValidBoundary() {
        let vm = makeViewModel()
        vm.name = "Mo"
        vm.breedName = "Bengal"
        vm.breedId = "beng"

        let advanced = vm.validateAndAdvance()

        #expect(advanced)
        #expect(vm.currentStep == 1)
        #expect(vm.step1Errors.isEmpty)
    }

    @Test("step 1 advances with valid name and breed")
    func step1Valid() {
        let vm = makeViewModel()
        vm.name = "Whiskers"
        vm.breedName = "Abyssinian"
        vm.breedId = "abys"

        let advanced = vm.validateAndAdvance()

        #expect(advanced)
        #expect(vm.currentStep == 1)
        #expect(vm.step1Errors.isEmpty)
    }

    // MARK: - Error Clearing

    @Test("clearing step 1 name error removes only that error")
    func clearStep1NameError() {
        let vm = makeViewModel()

        _ = vm.validateAndAdvance()
        #expect(vm.step1Errors["name"] != nil)
        #expect(vm.step1Errors["breed"] != nil)

        vm.clearStep1Error(for: "name")

        #expect(vm.step1Errors["name"] == nil)
        #expect(vm.step1Errors["breed"] != nil)
    }

    // MARK: - Breed Loading

    @Test("fetches breeds successfully")
    func fetchBreedsSuccess() async throws {
        let service = MockCatBreedsService(result: .success(Self.sampleBreeds))
        let vm = AddCatViewModel(service: service)

        vm.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        if case .loaded(let breeds) = vm.breedsState {
            #expect(breeds.count == 2)
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test("fetches breeds with error")
    func fetchBreedsError() async throws {
        let service = MockCatBreedsService(
            result: .failure(.serverError(statusCode: 500, data: Data()))
        )
        let vm = AddCatViewModel(service: service)

        vm.fetchBreeds()
        try await Task.sleep(for: Self.testSleepDuration)

        if case .error(let msg) = vm.breedsState {
            #expect(!msg.isEmpty)
        } else {
            Issue.record("Expected error state")
        }
    }

    // MARK: - Step 2 Validation

    @Test("step 2 fails with empty age")
    func step2EmptyAge() {
        let vm = advanceToStep2()

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.currentStep == 1)
        #expect(vm.step2Errors["age"] != nil)
    }

    @Test("step 2 fails with non-numeric age")
    func step2NonNumericAge() {
        let vm = advanceToStep2()
        vm.age = "abc"
        vm.shortDescription = "A lovely cat indeed"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step2Errors["age"] != nil)
    }

    @Test("step 2 fails with age 0")
    func step2AgeZero() {
        let vm = advanceToStep2()
        vm.age = "0"
        vm.shortDescription = "A lovely cat indeed"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step2Errors["age"] != nil)
    }

    @Test("step 2 fails with age 31")
    func step2AgeTooHigh() {
        let vm = advanceToStep2()
        vm.age = "31"
        vm.shortDescription = "A lovely cat indeed"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step2Errors["age"] != nil)
    }

    @Test("step 2 fails with short description")
    func step2ShortDescription() {
        let vm = advanceToStep2()
        vm.age = "5"
        vm.shortDescription = "Short"

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step2Errors["shortDescription"] != nil)
    }

    @Test("step 2 fails with whitespace-only description")
    func step2WhitespaceDescription() {
        let vm = advanceToStep2()
        vm.age = "5"
        vm.shortDescription = "          "

        let advanced = vm.validateAndAdvance()

        #expect(!advanced)
        #expect(vm.step2Errors["shortDescription"] != nil)
    }

    @Test("step 2 advances with valid age (boundary 1) and description (boundary 10 chars)")
    func step2ValidBoundary() {
        let vm = advanceToStep2()
        vm.age = "1"
        vm.shortDescription = "Exactly 10"

        let advanced = vm.validateAndAdvance()

        #expect(advanced)
        #expect(vm.currentStep == 2)
        #expect(vm.step2Errors.isEmpty)
    }

    @Test("step 2 advances with age 30 (upper boundary)")
    func step2ValidUpperBoundary() {
        let vm = advanceToStep2()
        vm.age = "30"
        vm.shortDescription = "A lovely cat indeed"

        let advanced = vm.validateAndAdvance()

        #expect(advanced)
        #expect(vm.currentStep == 2)
    }

    @Test("clearing step 2 age error removes only that error")
    func clearStep2AgeError() {
        let vm = advanceToStep2()

        _ = vm.validateAndAdvance()
        #expect(vm.step2Errors["age"] != nil)
        #expect(vm.step2Errors["shortDescription"] != nil)

        vm.clearStep2Error(for: "age")

        #expect(vm.step2Errors["age"] == nil)
        #expect(vm.step2Errors["shortDescription"] != nil)
    }

    // MARK: - Save

    @Test("save creates a RegisteredCat with correct fields")
    func saveCreatesCorrectCat() throws {
        let container = try ModelContainer(
            for: RegisteredCat.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let vm = advanceToStep2()
        vm.age = "5"
        vm.shortDescription = "A lovely friendly cat"
        vm.color = CatColor.orange.rawValue
        vm.gender = .male
        _ = vm.validateAndAdvance()

        vm.save(context: context)

        #expect(vm.isSaved)

        let descriptor = FetchDescriptor<RegisteredCat>()
        let cats = try context.fetch(descriptor)
        #expect(cats.count == 1)

        let cat = try #require(cats.first)
        #expect(cat.name == "Whiskers")
        #expect(cat.breedName == "Bengal")
        #expect(cat.breedId == "beng")
        #expect(cat.age == 5)
        #expect(cat.shortDescription == "A lovely friendly cat")
        #expect(cat.color == "orange")
        #expect(cat.gender == CatGender.male.rawValue)
    }

    // MARK: - Reset

    @Test("reset clears all fields and returns to step 0")
    func resetClearsEverything() {
        let vm = advanceToStep2()
        vm.age = "5"
        vm.shortDescription = "A lovely friendly cat"
        vm.color = CatColor.orange.rawValue
        vm.gender = .male
        _ = vm.validateAndAdvance()

        vm.reset()

        #expect(vm.currentStep == 0)
        #expect(vm.name.isEmpty)
        #expect(vm.breedName.isEmpty)
        #expect(vm.breedId.isEmpty)
        #expect(vm.age.isEmpty)
        #expect(vm.shortDescription.isEmpty)
        #expect(vm.color.isEmpty)
        #expect(vm.gender == .unknown)
        #expect(vm.photo == nil)
        #expect(vm.step1Errors.isEmpty)
        #expect(vm.step2Errors.isEmpty)
        #expect(!vm.isSaved)
    }

    // MARK: - Navigation

    @Test("goBack decrements step")
    func goBack() {
        let vm = makeViewModel()
        vm.name = "Whiskers"
        vm.breedName = "Bengal"
        vm.breedId = "beng"

        _ = vm.validateAndAdvance()
        #expect(vm.currentStep == 1)

        vm.goBack()
        #expect(vm.currentStep == 0)
    }

    @Test("goBack does nothing on step 0")
    func goBackOnFirstStep() {
        let vm = makeViewModel()
        vm.goBack()
        #expect(vm.currentStep == 0)
    }

    // MARK: - Helpers

    private func makeViewModel() -> AddCatViewModel {
        AddCatViewModel(service: MockCatBreedsService(result: .success(Self.sampleBreeds)))
    }

    private func advanceToStep2() -> AddCatViewModel {
        let vm = makeViewModel()
        vm.name = "Whiskers"
        vm.breedName = "Bengal"
        vm.breedId = "beng"
        _ = vm.validateAndAdvance()
        return vm
    }
}
