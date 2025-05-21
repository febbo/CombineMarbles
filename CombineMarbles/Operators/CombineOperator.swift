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
            createFilterOperator(),
            createFilterWhereOperator(),
            createRemoveDuplicatesOperator(),
            createPrefixOperator(),
            createDropWhileOperator(),
            createDropFirstOperator(),
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
        
    func createFilterOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "filter",
            category: .filtering,
            description: "Publishes only elements from an upstream publisher that satisfy a provided predicate.",
            codeExample: """
            publisherA
                .filter { $0 > 50 }
            """,
            inputStrategies: [.filterDemonstration()],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .filter { value in
                        // Filtra solo valori superiori a 50
                        if let intValue = value as? Int {
                            return intValue > 50
                        }
                        return false
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
    func createRemoveDuplicatesOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "removeDuplicates",
            category: .filtering,
            description: "Publishes only elements that don't match the previous element, using the provided predicate to determine the uniqueness.",
            codeExample: """
            publisherA
                .removeDuplicates()
            """,
            inputStrategies: [.custom({ streamViewModel in
                // Generiamo dati con valori duplicati consecutivi per dimostrare l'operatore
                streamViewModel.reset()
                let timelineDuration = streamViewModel.timelineDuration
                
                // Sequenza con duplicati
                let values = [10, 10, 20, 30, 30, 30, 40, 50, 50]
                let count = values.count
                let interval = (timelineDuration * 0.8) / Double(count)
                
                for (i, value) in values.enumerated() {
                    let time = Double(i) * interval + 0.5
                    streamViewModel.setCurrentTime(time)
                    streamViewModel.addEvent(.next(value))
                }
                
                streamViewModel.setCurrentTime(timelineDuration * 0.9)
                streamViewModel.addEvent(.completed)
            })],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .removeDuplicates { prev, current in
                        // Confronto di uguaglianza per rimuovere duplicati
                        if let prevInt = prev as? Int, let currentInt = current as? Int {
                            return prevInt == currentInt
                        }
                        return false
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
    func createPrefixOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "prefix(_:)",
            category: .filtering,
            description: "Republishes elements up to the specified maximum count, then finishes.",
            codeExample: """
            publisherA
                .prefix(3)
            """,
            inputStrategies: [.prefixDropDemonstration()],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .prefix(3)
                    .eraseToAnyPublisher()
            }
        )
    }
    
    //advanced filter
    func createFilterWhereOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "filter(isMultipleOf:)",
            category: .filtering,
            description: "A variant of filter that shows how to filter elements based on a specific condition - in this case numbers that are multiples of 3.",
            codeExample: """
            publisherA
                .filter { $0.isMultiple(of: 3) }
            """,
            inputStrategies: [.custom { streamViewModel in
                streamViewModel.reset()
                let timelineDuration = streamViewModel.timelineDuration
                
                let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                let count = values.count
                let interval = (timelineDuration * 0.8) / Double(count)
                
                for (i, value) in values.enumerated() {
                    let time = Double(i) * interval + 0.5
                    streamViewModel.setCurrentTime(time)
                    streamViewModel.addEvent(.next(value))
                }
                
                streamViewModel.setCurrentTime(timelineDuration * 0.9)
                streamViewModel.addEvent(.completed)
            }],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .filter { value in
                        if let intValue = value as? Int {
                            return intValue.isMultiple(of: 3)
                        }
                        return false
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
    
    func createDropWhileOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "drop(while:)",
            category: .filtering,
            description: "Ignores elements from the upstream publisher until the provided predicate returns false, then publishes all remaining elements.",
            codeExample: """
            publisherA
                .drop(while: { $0 < 40 })
            """,
            inputStrategies: [.dropWhileDemonstration()],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .drop(while: { value in
                        if let intValue = value as? Int {
                            return intValue < 40
                        }
                        return false
                    })
                    .eraseToAnyPublisher()
            }
        )
    }
    
    func createDropFirstOperator() -> OperatorDefinition {
        return OperatorDefinition(
            name: "dropFirst(_:)",
            category: .filtering,
            description: "Ignores the first specified number of elements from the upstream publisher, then publishes all remaining elements.",
            codeExample: """
            publisherA
                .dropFirst(3)
            """,
            inputStrategies: [.sequenceOperatorDemonstration()],
            apply: { publishers in
                guard let publisher = publishers.first else {
                    return Empty().eraseToAnyPublisher()
                }
                
                return publisher
                    .dropFirst(3)
                    .eraseToAnyPublisher()
            }
        )
    }
    
}
}
