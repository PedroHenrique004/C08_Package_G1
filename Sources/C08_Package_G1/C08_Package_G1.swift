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
    private static let sharedModel: VNCoreMLModel = {
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
    public static func analyze(image: UIImage?) async -> Bool {
        // Valida e converte a UIImage para CGImage em um único passo.
        guard let cgImage = image?.cgImage else {
            print("Nenhuma imagem válida fornecida para análise.")
            return false
        }
        
        // Converte a lógica de completion handler do Vision para o moderno async/await.
        return await withCheckedContinuation { continuation in
            // Cria e configura a requisição de análise.
            let request = VNCoreMLRequest(model: sharedModel) { request, error in
                // Após a análise, verifica os resultados.
                guard let results = request.results as? [VNClassificationObservation],
                      let bestResult = results.first, error == nil else {
                    print("🚨 Erro ou nenhum resultado retornado pela análise: \(error?.localizedDescription ?? "N/A")")
                    continuation.resume(returning: false)
                    return
                }
                
                // Processa o melhor resultado.
                let isPet = bestResult.identifier == "pets"
                
                // Cria uma instância da nossa struct para usar a formatação da porcentagem.
                let classification = Classification(label: bestResult.identifier, confidence: bestResult.confidence)

                print("\n---------------------------------")
                print("Resultado da Análise do Pacote:")
                print("   - \(isPet ? "✅ É um Pet!" : "❌ Não é um Pet.")")
                print("   - Label Detectada: '\(classification.label)'")
                print("   - Confiança: \(classification.confidencePercentage)")
                print("---------------------------------")
                continuation.resume(returning: isPet)
            }
            request.imageCropAndScaleOption = .centerCrop
            
            // Executa a requisição.
            do {
                try VNImageRequestHandler(cgImage: cgImage).perform([request])
            } catch {
                print("🚨 Falha ao executar a requisição do Vision: \(error.localizedDescription)")
                continuation.resume(returning: false)
            }
        }
    }
}
//
//
//// MARK: - Classificador de Pets
//
///// Esta classe é a interface principal para o modelo de Machine Learning.
//public class PetClassifier {
//    
//    // MARK: - Carregamento do Modelo
//    // static let garante que o modelo seja carregado da memória *apenas uma vez*, na primeira vez que for necessário.
//    ///   Isso é muito eficiente, pois carregar o modelo pode ser uma operação lenta. A partir daí, ele fica pronto para ser usado rapidamente em todas as chamadas futuras.
//    private static let modeloCoreML: VNCoreMLModel = {
//        do {
//            // `PetClassifierModel()` é a classe que o Xcode gerou automaticamente a partir do seu arquivo .mlmodel.
//            let configuracao = MLModelConfiguration()
//            let modelo = try PetClassifierModel(configuration: configuracao).model
//            
//            // O framework Vision precisa de um "invólucro" especial para o modelo Core ML. É isso que `VNCoreMLModel` faz.
//            return try VNCoreMLModel(for: modelo)
//        } catch {
//            // Se o modelo não puder ser carregado (ex: arquivo corrompido ou não encontrado), o app irá parar com uma mensagem clara.
//            fatalError("Falha crítica ao carregar o modelo de Core ML: \(error)")
//        }
//    }()
//    
//    // MARK: - Função Principal de Análise
//    
//    /// Analisa uma imagem para determinar se ela contém um pet.
//    // async: Esta palavra-chave indica que a função pode realizar um trabalho demorado (como analisar uma imagem)
//    ///   sem travar a interface do seu aplicativo. A palavra  ' await '  é usada ao chamá-la para esperar pela resposta.
//    /// - Parameter imagem: A `UIImage` opcional que você deseja analisar.
//    /// - Returns: `true` se a imagem for classificada como "pets", `false` caso contrário.
//    public static func analisar(imagem: UIImage?) async -> Bool {
//        
//        // Validando a Imagem de Entrada
//        // Primeiro, garantimos que a imagem recebida não é nula e pode ser convertida para o formato que o Vision entende (`CGImage`).
//        guard let imagemCG = imagem?.cgImage else {
//            print("Nenhuma imagem válida foi fornecida para análise.")
//            return false
//        }
//        
//        //2: Executando a Análise de Forma Assíncrona
//        // O framework Vision usa um estilo de programação mais antigo chamado "completion handler".
//        // `withCheckedContinuation` é uma "ponte" que nos permite usar esse código antigo dentro de uma função `async` moderna.
//        return await withCheckedContinuation { continuacao in
//            
//            // Cria uma requisição para o Vision, dizendo a ele para usar nosso modelo.
//            let requisicao = criarRequisicaoDeAnalise { resultado in
//                // Quando a análise terminar, este bloco de código será executado.
//                // O `resultado` pode ser `.success` ou `.failure`.
//                
//                // Processa o resultado e "desperta" a continuação com a resposta final (true ou false).
//                let isPet = processarResultadoDaAnalise(resultado)
//                continuacao.resume(returning: isPet)
//            }
//            
//            // Inicia o processo de análise da imagem com a requisição que acabamos de criar.
//            executarRequisicao(requisicao, na: imagemCG)
//        }
//    }
//    
//    // MARK: - Funções Auxiliares (Lógica Interna)
//    
//    /// Cria uma "requisição" (um pedido de trabalho) para o Vision.
//    private static func criarRequisicaoDeAnalise(completion: @escaping (Result<[VNClassificationObservation], Error>) -> Void) -> VNCoreMLRequest {
//        
//        // Diz ao Vision para usar nosso modelo carregado.
//        let requisicao = VNCoreMLRequest(model: modeloCoreML) { (request, error) in
//            // Este é o "completion handler". Ele é chamado pelo Vision quando a análise termina.
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let observacoes = request.results as? [VNClassificationObservation] else {
//                completion(.failure(ClassifierError.classificationFailed))
//                return
//            }
//            completion(.success(observacoes))
//        }
//        
//        // Configura como a imagem deve ser ajustada para o tamanho que o modelo espera.
//        requisicao.imageCropAndScaleOption = .centerCrop
//        return requisicao
//    }
//    
//    /// Envia a requisição para ser processada pelo Vision.
//    private static func executarRequisicao(_ requisicao: VNCoreMLRequest, na imagem: CGImage) {
//        // O `VNImageRequestHandler` é o "trabalhador" que efetivamente executa a análise na imagem.
//        let manipulador = VNImageRequestHandler(cgImage: imagem)
//        
//        // A análise é feita em uma thread de fundo para não travar a tela.
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try manipulador.perform([requisicao])
//            } catch {
//                print("🚨 Falha ao executar a requisição do Vision: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    /// Interpreta a resposta do Vision e retorna um booleano simples.
//    private static func processarResultadoDaAnalise(_ resultado: Result<[VNClassificationObservation], Error>) -> Bool {
//        switch resultado {
//        case .success(let observacoes):
//            // `observacoes` é uma lista de possíveis classificações, ordenada da mais provável para a menos provável.
//            // Pegamos a primeira, que é a melhor previsão do modelo.
//            guard let melhorResultado = observacoes.first else {
//                print("⚠️ O modelo não retornou nenhuma classificação.")
//                return false
//            }
//            
//            let isPet = melhorResultado.identifier == "pets"
//            let confianca = String(format: "%.1f%%", melhorResultado.confidence * 100)
//            
//            print("\n---------------------------------")
//            print("Resultado da Análise:")
//            print("   - Veredito: \(isPet ? "✅ É um Pet!" : "❌ Não é um Pet.")")
//            print("   - Label Detectada: '\(melhorResultado.identifier)'")
//            print("   - Confiança: \(confianca)")
//            print("---------------------------------")
//            
//            return isPet
//            
//        case .failure(let error):
//            print("🚨 Erro ao processar o resultado da análise: \(error.localizedDescription)")
//            return false
//        }
//    }
//}
//
///// Define um erro personalizado para o nosso classificador.
//public enum ClassifierError: Error {
//    case classificationFailed
//}
