//
//  File.swift
//  C08_Package_G1
//
//  Created by Thiago de Jesus on 30/09/25.
//

import Foundation
import UIKit

/// `PackageManager` necessario para analisar a imagem
/// com ele é possível utilizar a função `analisar` que é usada
/// para  analisar sua imagem
public struct PackageManager {
    
    public init(){
        
    }
    ///`analisar` é utilizada para retornar se a sua imagem passada é um pet ou não
    ///e se for um pet diz qual pet é entre `gato,cachorro, hamster, papagaio
    ///
    /// - Parameters:
    ///   - image: A `UIImage` opcional que será analisada. Caso seja `nil`, o resultado poderá não identificar nenhum pet.
    /// - Returns: Um objeto `ResponseAnalyze` contendo o nome do animal identificado (ou "Não Domestico") e se ele é considerado um pet.
    public func analyze(image: UIImage?) async -> ResponseAnalyze {
        
        let tipo = await PetClassifier.analyze(image: image, isPet: false)
        
        guard tipo == "pets" else {
            return ResponseAnalyze(name: "Não Domestico", isPet: false)
        }
        
        let nome = await PetClassifier.analyze(image: image, isPet: true)
        
        let response: ResponseAnalyze = ResponseAnalyze(name: nome, isPet: tipo == "pets" ? true : false)
        
        return response
    }
}
