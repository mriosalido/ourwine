import Foundation
import UIKit

// MARK: - Wine Service Protocol
protocol WineServicing {
    func fetchWines(page: Int, pageSize: Int) async throws -> [WineDTO]
    func addWine(_ wine: WineDTO) async throws
}

// MARK: - Storage Service Protocol
protocol StorageServicing {
    func uploadWinePhoto(_ data: Data, name: String) async throws
    func addWinePhotoMetadata(_ metadata: WinePhotoDTO) async throws
}

// MARK: - Data Transfer Objects (DTOs)
// Moveremos aquí los DTOs para que la capa de servicio sea autocontenida.

struct WineDTO: Codable, Equatable, Identifiable {
    let id: UUID
    let year: Int
    let name: String
    let winery: String
    let kind: WineKind
    let value: WineValue
    let notes: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, year, name, winery, kind, value, notes
        case createdAt = "created_at"
    }
}

struct WinePhotoDTO: Codable, Equatable, Identifiable {
    let id: UUID
    let wineId: UUID
    let storagePath: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case wineId = "wine_id"
        case storagePath = "storage_path"
        case createdAt = "created_at"
    }
} 