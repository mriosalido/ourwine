import Foundation
import Supabase

struct SupabaseService: WineServicing, StorageServicing {
    
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // MARK: - WineServicing Conformance
    
    func fetchWines(page: Int, pageSize: Int) async throws -> [WineDTO] {
        let from = page * pageSize
        let to = from + pageSize - 1
        
        let dtos: [WineDTO] = try await supabaseClient
            .from("wines")
            .select()
            .order("created_at", ascending: false)
            .range(from: from, to: to)
            .execute()
            .value
        
        return dtos
    }
    
    func addWine(_ wine: WineDTO) async throws {
        try await supabaseClient.from("wines").insert(wine).execute()
    }
    
    // MARK: - StorageServicing Conformance
    
    func uploadWinePhoto(_ data: Data, name: String) async throws {
        let bucket = Config.shared.supabaseBucket
        _ = try await supabaseClient.storage.from(bucket).upload(
            name,
            data: data,
            options: FileOptions(cacheControl: "3600", contentType: "image/jpeg")
        )
    }
    
    func addWinePhotoMetadata(_ metadata: WinePhotoDTO) async throws {
        try await supabaseClient.from("wine_photos").insert(metadata).execute()
    }
} 