import SwiftData
import Foundation

@Model
final class Tasting {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    
    // Para la geoposición
    var latitude: Double?
    var longitude: Double?

    // Relaciones con otros modelos
    var wine: Wine?
    @Relationship(deleteRule: .cascade, inverse: \TastingPhoto.tasting)
    var photos: [TastingPhoto]?
    var group: TastingGroup?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        latitude: Double? = nil,
        longitude: Double? = nil,
        wine: Wine? = nil,
        photos: [TastingPhoto]? = nil,
        group: TastingGroup? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.latitude = latitude
        self.longitude = longitude
        self.wine = wine
        self.photos = photos
        self.group = group
    }
}