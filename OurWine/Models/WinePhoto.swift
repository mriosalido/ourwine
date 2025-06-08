import Foundation
import SwiftData

@Model
final class WinePhoto: Identifiable {
    @Attribute(.unique) public var id: UUID
    var storagePath: String
    var createdAt: Date
    var wine: Wine?

    init(id: UUID, storagePath: String, createdAt: Date, wine: Wine? = nil) {
        self.id = id
        self.storagePath = storagePath
        self.createdAt = createdAt
        self.wine = wine
    }
    
    convenience init(from dto: WinePhotoDTO) {
        self.init(id: dto.id, storagePath: dto.storagePath, createdAt: dto.createdAt)
    }
} 