import Foundation
import NetworkLayer

#if DEBUG
extension CatBreed {
    static let preview: CatBreed = {
        let json = Data("""
        {
            "id": "abys",
            "name": "Abyssinian",
            "description": "The Abyssinian is easy to care for, and a joy to have in your home. They're affectionate cats and love both people and other animals.",
            "origin": "Egypt",
            "temperament": "Active, Energetic, Independent, Intelligent, Gentle",
            "life_span": "14 - 15",
            "weight": { "imperial": "7 - 10", "metric": "3 - 5" },
            "reference_image_id": "0XYvRd7oD"
        }
        """.utf8)
        do {
            return try JSONDecoder().decode(CatBreed.self, from: json)
        } catch {
            fatalError("PreviewData: CatBreed JSON is invalid — \(error)")
        }
    }()
}
#endif
