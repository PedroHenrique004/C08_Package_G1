//
//  File.swift
//  C08_Package_G1
//
//  Created by Thiago de Jesus on 30/09/25.
//

import Foundation
import UIKit

public struct PackageManager {
    
    public init(){
        
    }
    
    public func analisar(image: UIImage?) async -> ResponseAnalyze {
        
        let tipo = await PetClassifier.analyze(image: image, isPet: false)
        
        guard tipo == "pets" else {
            return ResponseAnalyze(name: "Não Domestico", isPet: false)
        }
        
        let nome = await PetClassifier.analyze(image: image, isPet: true)
        
        let response: ResponseAnalyze = ResponseAnalyze(name: nome, isPet: tipo == "pets" ? true : false)
        
        return response
    }
}
