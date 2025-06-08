import SwiftData
import Foundation

@Model
final class User {
    @Attribute(.unique) var id: UUID
    
    /// El ID del proveedor de autenticación (p. ej., el ID de usuario de Supabase).
    /// Es crucial para vincular los datos locales con el usuario autenticado.
    @Attribute(.unique) var authId: String
    
    var username: String?
    var email: String?
    
    // Relación muchos a muchos con TastingGroup
    @Relationship(inverse: \TastingGroup.users)
    var tastingGroups: [TastingGroup]?
    
    init(
        id: UUID = UUID(),
        authId: String,
        username: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.authId = authId
        self.username = username
        self.email = email
    }
} 