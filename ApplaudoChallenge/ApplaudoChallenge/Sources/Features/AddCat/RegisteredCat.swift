import Foundation
import SwiftData

enum CatGender: String, CaseIterable, Codable {
    case male, female

    var displayName: String {
        rawValue.capitalized
    }
}

enum CatColor: String, CaseIterable {
    case black, white, gray, orange, brown, cream
    case calico, tabby, tortoiseshell, bicolor, tuxedo, siamese
    case other

    var displayName: String {
        switch self {
        case .tortoiseshell: return "Tortoiseshell"
        default: return rawValue.capitalized
        }
    }
}

@Model
final class RegisteredCat: Hashable {
    static func == (lhs: RegisteredCat, rhs: RegisteredCat) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }

    var name: String
    var breedName: String
    var breedId: String
    var age: Int
    var shortDescription: String
    var color: String
    var gender: String
    @Attribute(.externalStorage) var photo: Data?
    var createdAt: Date

    init(
        name: String,
        breedName: String,
        breedId: String,
        age: Int,
        shortDescription: String,
        color: String,
        gender: CatGender,
        photo: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.breedName = breedName
        self.breedId = breedId
        self.age = age
        self.shortDescription = shortDescription
        self.color = color
        self.gender = gender.rawValue
        self.photo = photo
        self.createdAt = createdAt
    }
}
