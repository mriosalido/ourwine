import SwiftUI
import SwiftData

struct AddTastingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Wine.name) private var wines: [Wine]
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedWine: Wine?
    @State private var showingWineSearch = false
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    private var isFormValid: Bool {
        selectedWine != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vino a Catar")) {
                    HStack {
                        Text("Vino")
                        Spacer()
                        Text(selectedWine?.name ?? "Seleccionar")
                            .foregroundColor(selectedWine == nil ? .secondary : .primary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingWineSearch = true
                    }
                }
                
                Section(header: Text("Ubicación")) {
                    locationView
                }
            }
            .navigationTitle("Nueva Cata")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTasting()
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showingWineSearch) {
                WineSearchView(selectedWine: $selectedWine)
            }
            .onChange(of: locationManager.location) { _, newLocation in
                if let location = newLocation {
                    self.latitude = location.latitude
                    self.longitude = location.longitude
                }
            }
        }
    }
    
    @ViewBuilder
    private var locationView: some View {
        switch locationManager.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            Button("Obtener ubicación actual") {
                locationManager.requestLocation()
            }
        case .authorizedAlways, .authorizedWhenInUse:
            if let lat = latitude, let lon = longitude {
                HStack {
                    Text("Lat: \(lat, specifier: "%.4f")")
                    Spacer()
                    Text("Lon: \(lon, specifier: "%.4f")")
                }
            } else {
                ProgressView()
                    .onAppear {
                        locationManager.requestLocation()
                    }
            }
        @unknown default:
            Text("Estado de ubicación desconocido")
        }
    }
    
    private func saveTasting() {
        guard let wine = selectedWine else { return }
        
        let newTasting = Tasting(
            latitude: self.latitude,
            longitude: self.longitude,
            wine: wine
        )
        modelContext.insert(newTasting)
    }
} 