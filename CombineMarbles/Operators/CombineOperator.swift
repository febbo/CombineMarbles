//
//  CombineOperator.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import Foundation
import Combine

enum OperatorCategory: String, CaseIterable {
    case transforming = "Transforming"
    case filtering = "Filtering"
    case combining = "Combining"
    case timing = "Timing"
    case sequence = "Sequence"
    case error = "Error Handling"
}

struct OperatorDefinition: Identifiable {
    let id = UUID()
    let name: String
    let category: OperatorCategory
    let description: String
    let codeExample: String
    let apply: ([AnyPublisher<Any, Error>]) -> AnyPublisher<Any, Error>
    let inputStrategy: InputGenerationStrategy
    
    init(name: String,
         category: OperatorCategory,
         description: String,
         codeExample: String,
         apply: @escaping ([AnyPublisher<Any, Error>]) -> AnyPublisher<Any, Error>,
         inputStrategy: InputGenerationStrategy = .random) {
        self.name = name
        self.category = category
        self.description = description
        self.codeExample = codeExample
        self.apply = apply
        self.inputStrategy = inputStrategy
    }
}

class OperatorLibrary {
    static let shared = OperatorLibrary()
    
    let operators: [OperatorDefinition] = [
        OperatorDefinition(
            name: "map",
            category: .transforming,
            description: "Transforms elements from the upstream publisher by applying a closure to each element.",
            codeExample: """
            publisherA
                .map { $0 * 2 }
            """,
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .map { value in
                        if let intValue = value as? Int {
                            return intValue * 2 as Any
                        }
                        return value
                    }
                    .eraseToAnyPublisher()
            }
        ),
        
        // TODO: Aggiungere altri operatori qui
    ]
}
