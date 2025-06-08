import SwiftUI
import SwiftData

struct AddWineView: View {
    // La vista solo se encarga de los datos del formulario
    @State private var name: String
    @State private var winery: String
    @State private var year: Int
    @State private var kind: WineKind = .tinto
    @State private var value: WineValue = .estaBien
    @State private var notes: String = ""
    
    @State private var errorMessage: String?
    
    // Closure para devolver los datos del vino creado
    var onSave: (String, String, Int, WineKind, WineValue, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: .now)
        return Array( (currentYear - 100)...currentYear ).reversed()
    }
    
    init(parsedInfo: ParsedWineInfo? = nil, onSave: @escaping (String, String, Int, WineKind, WineValue, String?) -> Void) {
        _name = State(initialValue: parsedInfo?.name ?? "")
        _winery = State(initialValue: parsedInfo?.winery ?? "")
        _year = State(initialValue: parsedInfo?.year ?? Calendar.current.component(.year, from: .now))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Vino")) {
                    TextField("Nombre del vino", text: $name)
                    TextField("Bodega", text: $winery)
                    Picker("Año", selection: $year) {
                        ForEach(yearRange, id: \.self) { year in Text(String(year)) }
                    }
                }
                Section(header: Text("Clasificación")) {
                    Picker("Tipo", selection: $kind) {
                        ForEach(WineKind.allCases) { kind in Text(kind.rawValue).tag(kind) }
                    }
                    Picker("Valoración", selection: $value) {
                        ForEach(WineValue.allCases) { value in Text(value.rawValue).tag(value) }
                    }
                }
                Section(header: Text("Notas")) {
                    TextEditor(text: $notes).frame(height: 100)
                }
                if let error = errorMessage {
                    Section { Text(error).foregroundColor(.red) }
                }
            }
            .navigationTitle("Añadir Vino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar", action: saveWine)
                }
            }
        }
    }
    
    private func saveWine() {
        guard !name.isEmpty, !winery.isEmpty else {
            errorMessage = "Por favor, completa los campos de nombre y bodega."
            return
        }
        
        onSave(name, winery, year, kind, value, notes.isEmpty ? nil : notes)
        dismiss()
    }
}
