// The Swift Programming Language
// https://docs.swift.org/swift-book
@preconcurrency import Vision
import UIKit // Precisamos importar UIKit para usar UIImage

// MARK: -  Classificador de Pets
public struct Classification {
    public let label: String
    public let confidence: Float
    public var confidencePercentage: String {
        return String(format: "%.1f%%", confidence * 100)
    }
}

/// Define os tipos de erros que podem ocorrer durante a classificação.
public enum ClassifierError: Error {
    case modelLoadingFailed(Error), imageProcessingFailed(Error), classificationFailed
}

// MARK: - Classificador Principal

/// A classe principal para interagir com o modelo de classificação de pets.
public class PetClassifier {
    // O modelo de Core ML é carregado uma única vez e compartilhado por todas as chamadas.
    private static let petDetector: VNCoreMLModel = {
        do {
            let configuracao = MLModelConfiguration()
            let modelo = try PetDetector(configuration: configuracao).model
            return try VNCoreMLModel(for: modelo)
        } catch {
            fatalError("Falha crítica ao carregar o modelo de Core ML: \(error)")
        }
    }()
    
    private static let petClassifierModel: VNCoreMLModel = {
        do {
            let configuracao = MLModelConfiguration()
            let modelo = try PetClassifierModel(configuration: configuracao).model
            return try VNCoreMLModel(for: modelo)
        } catch {
            fatalError("Falha crítica ao carregar o modelo de Core ML: \(error)")
        }
    }()
    
    /// Analisa uma imagem para determinar se ela contém um pet. É a única função que você precisa chamar.
    /// Exemplo de uso: `let isPet = await PetClassifier.analyze(image: suaImagem)`
    public static func analyze(image: UIImage?, isPet: Bool) async -> String {
        
        var model: VNCoreMLModel
        
        if isPet {
            model = petDetector
        } else {
            model = petClassifierModel
        }
        
        // Valida e converte a UIImage para CGImage em um único passo.
        guard let cgImage = image?.cgImage else {
            print("Nenhuma imagem válida fornecida para análise.")
            return ""
        }
        
        // Converte a lógica de completion handler do Vision para o moderno async/await.
        return await withCheckedContinuation { continuation in
            // Cria e configura a requisição de análise.
            let request = VNCoreMLRequest(model: model) { request, error in
                // Após a análise, verifica os resultados.
                guard let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first, error == nil else {
                    print("🚨 Erro ou nenhum resultado retornado pela análise: \(error?.localizedDescription ?? "N/A")")
                    continuation.resume(returning: "")
                    return
                }
                
                // Processa o melhor resultado.
                let isPet = bestResult.identifier
                
                // Cria uma instância da nossa struct para usar a formatação da porcentagem.
                let classification = Classification(label: bestResult.identifier, confidence: bestResult.confidence)

                continuation.resume(returning: isPet)
            }
            request.imageCropAndScaleOption = .centerCrop
            
            // Executa a requisição.
            do {
                try VNImageRequestHandler(cgImage: cgImage).perform([request])
            } catch {
                print("Falha ao executar a requisição do Vision: \(error.localizedDescription)")
                continuation.resume(returning: "")
            }
        }
    }
}
