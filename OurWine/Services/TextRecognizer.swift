import Vision
import UIKit

struct TextRecognizer {
    enum RecognizerError: Error {
        case cgImageCreationError
        case recognitionFailed(Error)
        case noTextFound
    }

    static func recognizeText(from image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw RecognizerError.cgImageCreationError
        }

        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { (request, error) in
                if let error = error {
                    continuation.resume(throwing: RecognizerError.recognitionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(throwing: RecognizerError.noTextFound)
                    return
                }

                // Devolvemos el texto de cada bloque reconocido
                let recognizedStrings = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }
                
                continuation.resume(returning: recognizedStrings)
            }
            
            // Priorizamos la precisión sobre la velocidad
            request.recognitionLevel = .accurate

            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: RecognizerError.recognitionFailed(error))
            }
        }
    }
} 