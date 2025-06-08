import Foundation

/// Una estructura para contener la información extraída del OCR.
struct ParsedWineInfo {
    var name: String?
    var winery: String?
    var year: Int?
}

/// Un servicio para analizar el texto de una etiqueta de vino.
struct WineInfoParser {
    static func parse(texts: [String]) -> ParsedWineInfo {
        var info = ParsedWineInfo()
        var potentialTexts = texts

        // 1. Encontrar el Año: Buscamos un número de 4 dígitos que parezca un año.
        if let yearIndex = potentialTexts.firstIndex(where: { isPotentialYear($0) }) {
            let yearString = potentialTexts.remove(at: yearIndex)
            info.year = Int(yearString.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        // 2. Encontrar la Bodega: Buscamos palabras clave como "Bodega", "Château", etc.
        let wineryKeywords = ["bodega", "celler", "château", "domaine", "winery", "vineyard", "vignobles", "bodegas"]
        if let wineryIndex = potentialTexts.firstIndex(where: { text in
            wineryKeywords.contains(where: { keyword in text.lowercased().contains(keyword) })
        }) {
            info.winery = potentialTexts.remove(at: wineryIndex).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 3. Encontrar el Nombre: Una heurística simple es suponer que el texto más largo
        // o uno de los primeros es el nombre del vino. Por ahora, cogeremos el primero que no esté vacío.
        if let name = potentialTexts.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            info.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return info
    }

    /// Comprueba si un texto puede ser un año de cosecha válido.
    private static func isPotentialYear(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let year = Int(trimmed) else { return false }
        let currentYear = Calendar.current.component(.year, from: .now)
        // Un vino no puede ser del futuro y raramente tendrá más de 120 años.
        return trimmed.count == 4 && year >= 1900 && year <= currentYear
    }
} 