import SwiftUI
import Supabase
import SwiftData

fileprivate enum SheetType: Identifiable {
    case manualAdd
    case scannedAdd(ParsedWineInfo)

    var id: String {
        switch self {
        case .manualAdd: return "manual"
        case .scannedAdd: return "scanned"
        }
    }
}

struct WineListView: View {
    @EnvironmentObject private var viewModel: WineListViewModel
    @Query(sort: \Wine.createdAt, order: .reverse) private var wines: [Wine]
    
    @State private var activeSheet: SheetType?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var isRecognizingText = false
    @State private var showingAddOptions = false
    @State private var isCameraAvailable = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                content
                fab
            }
            .navigationTitle("Mis Vinos")
            .confirmationDialog("Añadir un vino", isPresented: $showingAddOptions, titleVisibility: .visible) {
                Button("Escanear con Cámara") {
                    showingCamera = true
                }
                .disabled(!isCameraAvailable)
                
                Button("Escanear de Galería") { showingImagePicker = true }
                Button("Añadir Manualmente") { activeSheet = .manualAdd }
                Button("Cancelar", role: .cancel) { }
            }
            .sheet(item: $activeSheet) {
                selectedImage = nil
            } content: { sheetType in
                switch sheetType {
                case .manualAdd:
                    AddWineView { name, winery, year, kind, value, notes in
                        Task {
                            await viewModel.save(name: name, winery: winery, year: year, kind: kind, value: value, notes: notes, photo: nil)
                        }
                    }
                case .scannedAdd(let info):
                    AddWineView(parsedInfo: info) { name, winery, year, kind, value, notes in
                        Task {
                            await viewModel.save(name: name, winery: winery, year: year, kind: kind, value: value, notes: notes, photo: selectedImage)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                processImage(newImage)
            }
            .onAppear {
                if wines.isEmpty {
                    Task {
                        await viewModel.fetchWines()
                    }
                }
                
                Task(priority: .userInitiated) {
                    guard !isCameraAvailable else { return }
                    let available = UIImagePickerController.isSourceTypeAvailable(.camera)
                    await MainActor.run {
                        self.isCameraAvailable = available
                    }
                }
            }
        }
    }
    
    // MARK: - Vistas Descompuestas
    
    @ViewBuilder
    private var content: some View {
        VStack {
            if let image = selectedImage {
                scannedImageView(image)
            }
            
            if wines.isEmpty && selectedImage == nil {
                if viewModel.isLoading {
                    ProgressView("Cargando vinos...")
                } else {
                    emptyView
                }
            } else {
                wineList
            }
        }
    }
    
    private var fab: some View {
        Button(action: { showingAddOptions = true }) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 5, x: 0, y: 5)
        }
        .padding()
    }
    
    private func scannedImageView(_ image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding()
            
            if isRecognizingText {
                ProgressView("Analizando etiqueta...")
                    .padding()
            }
        }
    }
    
    private var emptyView: some View {
        Text("No tienes vinos en tu colección.\n¡Añade el primero!")
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var wineList: some View {
        List(wines) { wine in
            HStack(spacing: 15) {
                if let firstPhoto = wine.photos?.first {
                    RemoteImage(storagePath: firstPhoto.storagePath)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(wine.name).font(.headline)
                    Text(wine.winery).font(.subheadline)
                    Text("Año: \(String(wine.year))").font(.caption).foregroundColor(.secondary)
                }
            }
            .onAppear {
                if wine.id == wines.last?.id {
                    Task {
                        await viewModel.fetchWines()
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading && !wines.isEmpty {
                VStack {
                    Spacer()
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Lógica de Procesamiento
    
    private func processImage(_ newImage: UIImage?) {
        guard let image = newImage else { return }
        
        isRecognizingText = true
        Task {
            defer { isRecognizingText = false }
            
            do {
                let recognizedTexts = try await TextRecognizer.recognizeText(from: image)
                let parsedInfo = WineInfoParser.parse(texts: recognizedTexts)
                activeSheet = .scannedAdd(parsedInfo)
            } catch {
                print("Error en el OCR: \(error)")
                // Aquí podríamos mostrar una alerta al usuario
            }
        }
    }
}
