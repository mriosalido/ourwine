import Foundation
import SwiftData

// Enum para el tipo de vino
enum WineKind: String, Codable, CaseIterable, Identifiable {
    case tinto = "Tinto"
    case blanco = "Blanco"
    case rosado = "Rosado"
    case espumoso = "Espumoso / Cava"
    case generoso = "Generoso / Dulce"
    
    var id: String { self.rawValue }
}

// Enum para la valoración del vino
enum WineValue: String, Codable, CaseIterable, Identifiable {
    case noMeGusta = "No me gusta"
    case estaBien = "Está bien"
    case repitoSeguro = "Repito seguro"
    
    var id: String { self.rawValue }
}

@Model
class Wine: Identifiable {
    @Attribute(.unique)
    var id: UUID
    var year: Int
    var name: String
    var winery: String
    var kind: WineKind
    var value: WineValue
    var notes: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var photos: [WinePhoto]? = []
    
    // Constructor para facilitar la creación de vinos y para usar en la app
    init(id: UUID = UUID(), year: Int, name: String, winery: String, kind: WineKind, value: WineValue, notes: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.year = year
        self.name = name
        self.winery = winery
        self.kind = kind
        self.value = value
        self.notes = notes
        self.createdAt = createdAt
    }
    
    // Conveniencia para crear un modelo desde un DTO
    convenience init(from dto: WineDTO) {
        self.init(id: dto.id, year: dto.year, name: dto.name, winery: dto.winery, kind: dto.kind, value: dto.value, notes: dto.notes, createdAt: dto.createdAt)
    }
}

// Para previews y testing
extension Wine {
    static let sample = Wine(
        year: 2021,
        name: "Vino de Ejemplo",
        winery: "Bodega Ficticia",
        kind: .tinto,
        value: .estaBien,
        notes: "Un vino de prueba con notas afrutadas."
    )
} 
