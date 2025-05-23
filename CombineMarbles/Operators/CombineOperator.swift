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
    let inputStrategies: [InputGenerationStrategy]
    let apply: ([AnyPublisher<Any, Error>]) -> AnyPublisher<Any, Error>
    
    init(name: String,
         category: OperatorCategory,
         description: String,
         codeExample: String,
         inputStrategies: [InputGenerationStrategy] = [.random],
         apply: @escaping ([AnyPublisher<Any, Error>]) -> AnyPublisher<Any, Error>) {
        self.name = name
        self.category = category
        self.description = description
        self.codeExample = codeExample
        self.inputStrategies = inputStrategies
        self.apply = apply
    }
}

class OperatorLibrary {
    static let shared = OperatorLibrary()
    
    var operators: [OperatorDefinition] {
        return [
            createMapOperator(),
            createCompactMapOperator(),
            // TODO: Add new operators here
        ]
    }
    
    private func createMapOperator() -> OperatorDefinition {
        return OperatorDefinition(
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
        )
    }
    
    private func createCompactMapOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "compactMap",
            category: .transforming,
            description: "Transforms all elements from the upstream publisher with a provided closure and publishes only non-nil results.",
            codeExample: """
            publisherA
                .compactMap { value in
                    value > 50 ? value : nil
                }
            """,
            inputStrategies: [.optionals],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .compactMap { value -> Any? in
                        if let strValue = value as? String, strValue == "nil" {
                            return nil
                        }
                        
                        if let intValue = value as? Int {
                            return intValue > 50 ? intValue : nil
                        }
                        return value
                    }
                    .eraseToAnyPublisher()
            }
            
        )
    }
}
