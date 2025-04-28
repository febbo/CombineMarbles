//
//  StreamEvent.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//  C

import Foundation

// Rappresentazione di un evento all'interno di uno stream
struct StreamEvent<T> {
    let value: T?
    let timestamp: TimeInterval
    let isError: Bool
    let isCompletion: Bool
    
    static func next(_ value: T, at timestamp: TimeInterval = 0) -> StreamEvent<T> {
        StreamEvent(value: value, timestamp: timestamp, isError: false, isCompletion: false)
    }
    
    static func completion(at timestamp: TimeInterval = 0) -> StreamEvent<T> {
        StreamEvent(value: nil, timestamp: timestamp, isError: false, isCompletion: true)
    }
    
    static func error(at timestamp: TimeInterval = 0) -> StreamEvent<T> {
        StreamEvent(value: nil, timestamp: timestamp, isError: true, isCompletion: false)
    }
}

// Rappresentazione di uno stream completo
struct EventStream<T> {
    let events: [StreamEvent<T>]
    let duration: TimeInterval
}

// Protocollo base per le trasformazioni
protocol StreamTransformation {
    associatedtype Input
    associatedtype Output
    
    var identifier: String { get }
    var displayName: String { get }
    var description: String { get }
    
    func transform(input: EventStream<Input>) -> EventStream<Output>
    func generateCode() -> String
}
