import SwiftData
import Foundation

@Model
final class TastingPhoto {
    @Attribute(.unique) var id: UUID
    var storagePath: String
    
    // Relación con la cata a la que pertenece
    var tasting: Tasting?
    
    init(id: UUID = UUID(), storagePath: String, tasting: Tasting? = nil) {
        self.id = id
        self.storagePath = storagePath
        self.tasting = tasting
    }
}