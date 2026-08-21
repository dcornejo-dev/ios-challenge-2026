import Foundation
import Testing
@testable import NetworkLayer

@Suite("CatBreed")
struct CatBreedTests {

    private func decode(_ json: String) throws -> CatBreed {
        let data = try #require(json.data(using: .utf8))
        return try JSONDecoder().decode(CatBreed.self, from: data)
    }

    @Test("imageURL builds CDN URL from referenceImageId")
    func imageURLWithReferenceImageId() throws {
        let breed = try decode("""
        {
            "id": "abys",
            "name": "Abyssinian",
            "description": "Active and playful breed",
            "origin": "Egypt",
            "temperament": "Active, Energetic",
            "life_span": "14 - 15",
            "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
            "reference_image_id": "abc123"
        }
        """)

        #expect(breed.imageURL == URL(string: "https://cdn2.thecatapi.com/images/abc123.jpg"))
    }

    @Test("imageURL returns nil when referenceImageId is nil")
    func imageURLWithNilReferenceImageId() throws {
        let breed = try decode("""
        {
            "id": "aege",
            "name": "Aegean",
            "description": "Native to Greece",
            "origin": "Greece",
            "temperament": "Affectionate, Social",
            "life_span": "9 - 12",
            "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
            "reference_image_id": null
        }
        """)

        #expect(breed.imageURL == nil)
    }
}
