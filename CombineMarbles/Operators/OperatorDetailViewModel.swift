//
//  Untitled.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import SwiftUI
import Combine

class OperatorDetailViewModel: ObservableObject {
    @Published var inputStreams: [MarbleStreamViewModel] = []
    @Published var outputStream = MarbleStreamViewModel(title: "Output")
    
    private var cancellables = Set<AnyCancellable>()
    
    // Align the output to the same time scale as the simulation used in MarbleStreamViewModel.asPublisher()
    // Note: keep these constants consistent with asPublisher (baseDelay: 0.05, span: 2.0s).
    private let simulationBaseDelay: TimeInterval = 0.05
    private let simulationSpan: TimeInterval = 2.0
    private var subscriptionStartDate: Date?
    
    // We plot the last emission of each input (relative time) to deduce the color in MERGE.
    private var lastInputEmissions: [TimeInterval?] = []
    private var inputTints: [Color] = []
    
    func runExample(with operator: OperatorDefinition) {
        setupInputStreams(for: `operator`)
        outputStream.reset()
        cancellables.removeAll()
        subscriptionStartDate = nil
        
        lastInputEmissions = Array(repeating: nil, count: inputStreams.count)
        
        // Apply input strategies
        for (index, inputStream) in inputStreams.enumerated() {
            if index < `operator`.inputStrategies.count {
                `operator`.inputStrategies[index].apply(to: inputStream)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Shared publishers so that they can be tracked and used in the operator without duplicating events
            self.subscriptionStartDate = Date()
            let sharedInputs: [AnyPublisher<Any, Error>] = self.inputStreams
                .map { $0.asPublisher().share().eraseToAnyPublisher() }
            
            // Input tracking: arrival time of the last value per stream
            for (idx, pub) in sharedInputs.enumerated() {
                pub
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { [weak self] _ in
                            guard let self = self else { return }
                            self.lastInputEmissions[idx] = self.elapsedSinceStart()
                        }
                    )
                    .store(in: &self.cancellables)
            }
            
            // Apply the operator to shared publishers
            let outputPublisher = `operator`.apply(sharedInputs)
            
            outputPublisher
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        
                        let elapsed = self.elapsedSinceStart()
                        let position = self.timelinePosition(fromElapsed: elapsed)
                        self.outputStream.setCurrentTime(position)
                        
                        switch completion {
                        case .finished:
                            self.outputStream.addEvent(.completed)
                        case .failure(let error):
                            self.outputStream.addEvent(.error(error))
                        }
                    },
                    receiveValue: { [weak self] value in
                        guard let self = self else { return }
                        
                        let elapsed = self.elapsedSinceStart()
                        let position = self.timelinePosition(fromElapsed: elapsed)
                        self.outputStream.setCurrentTime(position)
                        
                        // Output tint based on the operator's declared policy
                        let tint = self.tintForOutput(atElapsed: elapsed, operator: `operator`)
                        self.outputStream.addEvent(.next(value), tint: tint)
                    }
                )
                .store(in: &self.cancellables)
        }
    }
    
    // Calculate the seconds elapsed since the start of the subscription
    private func elapsedSinceStart() -> TimeInterval {
        guard let start = subscriptionStartDate else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    // Map the seconds elapsed at the position in the timeline (0...timelineDuration) consistent with MarbleStreamViewModel.asPublisher(): delay = baseDelay + normalizedPosition * 2.0
    private func timelinePosition(fromElapsed elapsed: TimeInterval) -> TimeInterval {
        let adjusted = max(0, elapsed - simulationBaseDelay) // remove initial simulation offset
        let normalized = max(0, min(1, adjusted / simulationSpan))
        return normalized * outputStream.timelineDuration
    }
    
    // Determine the tint to use in output based on the operator's policy
    private func tintForOutput(atElapsed elapsed: TimeInterval, operator: OperatorDefinition) -> Color? {
        switch `operator`.outputTintPolicy {
        case .none:
            return nil
            
        case .composed:
            // Composite values (e.g. zip/combineLatest)
            return .purple
            
        case .inheritNearestInput(let epsilon):
            // Choose the input stream whose last emission is closest in time to the output (within epsilon)
            var bestIdx: Int?
            var bestDelta = TimeInterval.greatestFiniteMagnitude
            
            for (idx, t) in lastInputEmissions.enumerated() {
                if let t {
                    let delta = abs(elapsed - t)
                    if delta < bestDelta && delta <= epsilon {
                        bestDelta = delta
                        bestIdx = idx
                    }
                }
            }
            if let idx = bestIdx, idx < inputTints.count {
                return inputTints[idx]
            }
            return nil
        }
    }
    
    // Method for configuring input streams based on the operator
    private func setupInputStreams(for operator: OperatorDefinition) {
        inputStreams.removeAll()
        inputTints.removeAll()
        
        // Input color palette
        let palette: [Color] = [.blue, .green, .orange, .pink, .teal, .indigo]
        
        for (index, _) in `operator`.inputStrategies.enumerated() {
            let streamTitle = inputStreams.isEmpty ? "Input" : "Input \(index + 1)"
            let inputStream = MarbleStreamViewModel(title: streamTitle)
            let tint = palette[index % palette.count]
            inputStream.defaultTint = tint
            inputStreams.append(inputStream)
            inputTints.append(tint)
        }
        
        if inputStreams.isEmpty {
            let stream = MarbleStreamViewModel(title: "Input")
            stream.defaultTint = palette.first
            inputStreams.append(stream)
            inputTints.append(palette.first ?? .blue)
        }
    }
}
