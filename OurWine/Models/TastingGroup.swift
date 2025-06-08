import SwiftData
import Foundation

@Model
final class TastingGroup {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    
    // Relación inversa para que SwiftData sepa que están conectadas
    @Relationship(inverse: \Tasting.group)
    var tastings: [Tasting]
    
    // Relación muchos a muchos con User
    var users: [User]?
    
    init(id: UUID = UUID(), name: String, createdAt: Date = Date(), tastings: [Tasting] = [], users: [User]? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.tastings = tastings
        self.users = users
    }
} 