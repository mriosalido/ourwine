import SwiftUI
import SwiftData

struct WineSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Wine.name) private var allWines: [Wine]
    
    @Binding var selectedWine: Wine?
    
    @State private var searchText = ""
    
    private var filteredWines: [Wine] {
        if searchText.isEmpty {
            return allWines
        } else {
            return allWines.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.winery.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredWines) { wine in
                VStack(alignment: .leading) {
                    Text(wine.name).font(.headline)
                    Text(wine.winery).font(.subheadline).foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedWine = wine
                    dismiss()
                }
            }
            .navigationTitle("Buscar Vino")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar por nombre o bodega")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
} 