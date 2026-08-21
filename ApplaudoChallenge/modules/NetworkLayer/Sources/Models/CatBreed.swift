import Foundation

public struct CatBreed: Decodable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let origin: String
    public let temperament: String
    public let lifeSpan: String
    public let weight: Weight
    public let referenceImageId: String?

    public struct Weight: Decodable, Hashable {
        public let imperial: String
        public let metric: String
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, origin, temperament, weight
        case lifeSpan = "life_span"
        case referenceImageId = "reference_image_id"
    }
}
