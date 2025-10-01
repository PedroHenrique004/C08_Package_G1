//
//  File.swift
//  C08_Package_G1
//
//  Created by Thiago de Jesus on 30/09/25.
//

import Foundation
import UIKit

public struct PackageManager {
    func analisar(image: UIImage?) async -> ResponseAnalyze {
        
    let tipo = await PetClassifier.analyze(image: image, isPet: false)
    let nome = await PetClassifier.analyze(image: image, isPet: true)
        
    let response: ResponseAnalyze = ResponseAnalyze(name: nome, isPet: tipo == "pet" ? true : false)
        
    return response
    }
}
