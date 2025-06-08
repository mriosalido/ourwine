import Foundation
import UIKit
import Supabase
import SwiftData

@MainActor
class WineListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let wineService: WineServicing
    private let storageService: StorageServicing
    private let modelContext: ModelContext
    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMore = true

    init(
        wineService: WineServicing,
        storageService: StorageServicing,
        modelContext: ModelContext
    ) {
        self.wineService = wineService
        self.storageService = storageService
        self.modelContext = modelContext
    }

    func fetchWines() async {
        print("[Debug] fetchWines: Intentando obtener vinos...")
        guard !isLoading && canLoadMore else {
            print("[Debug] fetchWines: Abortado (isLoading: \(isLoading), canLoadMore: \(canLoadMore)).")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedDTOs = try await wineService.fetchWines(page: currentPage, pageSize: pageSize)
            
            print("[Debug] fetchWines: Se han obtenido \(fetchedDTOs.count) vinos del servicio.")
            
            if fetchedDTOs.count < pageSize {
                canLoadMore = false
            }
            
            for dto in fetchedDTOs {
                let wine = Wine(from: dto)
                // Nota: Esta es una inserción simple. Para una robustez total,
                // aquí se implementaría una lógica de "upsert" para evitar duplicados.
                modelContext.insert(wine)
            }
            try modelContext.save()
            
            print("[Debug] fetchWines: Vinos guardados en la base de datos local correctamente.")
            currentPage += 1
            
        } catch {
            print("[Debug] fetchWines: ❌ ERROR al obtener o guardar vinos: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func save(name: String, winery: String, year: Int, kind: WineKind, value: WineValue, notes: String?, photo: UIImage?) async {
        do {
            // 1. Crear el DTO del vino. El ID se genera aquí para usarlo en la foto.
            let wineId = UUID()
            let newWineDTO = WineDTO(
                id: wineId,
                year: year,
                name: name,
                winery: winery,
                kind: kind,
                value: value,
                notes: notes,
                createdAt: Date()
            )

            // 2. Guardar el vino usando el servicio
            print("[Debug] save: Guardando vino en la base de datos...")
            try await wineService.addWine(newWineDTO)

            var newWinePhoto: WinePhoto?

            // 3. Si hay foto, subirla y crear el DTO de la foto
            if let image = photo, let imageData = image.jpegData(compressionQuality: 0.8) {
                let photoName = "\(UUID().uuidString).jpg"
                
                print("[Debug] save: Subiendo foto \(photoName)...")
                try await storageService.uploadWinePhoto(imageData, name: photoName)
                
                let newPhotoDTO = WinePhotoDTO(
                    id: UUID(),
                    wineId: wineId,
                    storagePath: photoName,
                    createdAt: Date()
                )
                
                print("[Debug] save: Guardando metadatos de la foto...")
                try await storageService.addWinePhotoMetadata(newPhotoDTO)
                
                newWinePhoto = WinePhoto(from: newPhotoDTO)
            }
            
            // 4. Crear el modelo local y guardarlo en SwiftData
            let newWine = Wine(from: newWineDTO)
            if let photo = newWinePhoto {
                newWine.photos?.append(photo)
            }
            
            modelContext.insert(newWine)
            try modelContext.save()
            
            print("[Debug] save: Proceso de guardado completado.")
            
        } catch {
            errorMessage = error.localizedDescription
            print("[Debug] save: ❌ ERROR durante el proceso de guardado: \(error)")
        }
    }
} 
