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
            createMergeOperator(),
            createCombineLatestOperator(),
            createZipOperator(),
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
    
    private func createMergeOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "merge",
            category: .combining,
            description: "Combines elements from multiple publishers of the same type, delivering an interleaved sequence of elements.",
            codeExample: """
            publisherA
                .merge(with: publisherB)
            """,
            inputStrategies: [.random, .delayed],
            apply: { publishers in
                guard publishers.count >= 2 else {
                    return publishers.first ?? Empty().eraseToAnyPublisher()
                }
                
                let firstPublisher = publishers[0]
                let secondPublisher = publishers[1]
                
                return firstPublisher
                    .merge(with: secondPublisher)
                    .eraseToAnyPublisher()
            }
        )
    }
    
    private func createCombineLatestOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "combineLatest",
            category: .combining,
            description: "Combines the latest values from multiple publishers, emitting a tuple of values whenever any of the publishers emits a new value.",
            codeExample: """
            publisherA.combineLatest(publisherB)
                .map { valueA, valueB in
                    return valueA + valueB
                }
            """,
            inputStrategies: [.random, .delayed],
            apply: { publishers in
                guard publishers.count >= 2 else {
                    return publishers.first ?? Empty().eraseToAnyPublisher()
                }
                
                let firstPublisher = publishers[0]
                let secondPublisher = publishers[1]
                
                return firstPublisher.combineLatest(secondPublisher)
                    .map { (a, b) -> Any in
                        if let intA = a as? Int, let intB = b as? Int {
                            return intA + intB
                        }
                        return "\(a),\(b)"
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
    private func createZipOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "zip",
            category: .combining,
            description: "Combines elements from multiple publishers, emitting a tuple of values only when all publishers have emitted a new value.",
            codeExample: """
            publisherA.zip(publisherB)
                .map { valueA, valueB in
                    return "valueA - valueB"
                }
            """,
            inputStrategies: [.random, .delayed],
            apply: { publishers in
                guard publishers.count >= 2 else {
                    return publishers.first ?? Empty().eraseToAnyPublisher()
                }
                
                let firstPublisher = publishers[0]
                let secondPublisher = publishers[1]
                
                return firstPublisher.zip(secondPublisher)
                    .map { (a, b) -> Any in
                        if let intA = a as? Int, let intB = b as? Int {
                            return "\(intA)-\(intB)"
                        }
                        return "\(a)-\(b)"
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
}
