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
    
    func runExample(with operator: OperatorDefinition) {
        setupInputStreams(for: `operator`)
        outputStream.reset()
        cancellables.removeAll()
        subscriptionStartDate = nil
        
        for (index, inputStream) in inputStreams.enumerated() {
            if index < `operator`.inputStrategies.count {
                `operator`.inputStrategies[index].apply(to: inputStream)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Convert all input streams into publishers
            let inputPublishers = self.inputStreams.map { $0.asPublisher() }
            
            // Applies the operator to all input publishers
            let outputPublisher = `operator`.apply(inputPublishers)
            
            // Store the subscription start time to map the output to the timeline
            self.subscriptionStartDate = Date()
            
            outputPublisher
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        
                        // Place the completion at the actual point in time of the simulation
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
                        
                        // Place each value according to its actual arrival time
                        let elapsed = self.elapsedSinceStart()
                        let position = self.timelinePosition(fromElapsed: elapsed)
                        self.outputStream.setCurrentTime(position)
                        self.outputStream.addEvent(.next(value))
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
        let adjusted = max(0, elapsed - simulationBaseDelay) // rimuove l'offset iniziale della simulazione
        let normalized = max(0, min(1, adjusted / simulationSpan))
        return normalized * outputStream.timelineDuration
    }
    
    // Method for configuring input streams based on the operator
    private func setupInputStreams(for operator: OperatorDefinition) {
        
        inputStreams.removeAll()
        
        for (index, _) in `operator`.inputStrategies.enumerated() {
            let streamTitle = inputStreams.isEmpty ? "Input" : "Input \(index + 1)"
            let inputStream = MarbleStreamViewModel(title: streamTitle)
            inputStreams.append(inputStream)
        }
        
        if inputStreams.isEmpty {
            inputStreams.append(MarbleStreamViewModel(title: "Input"))
        }
    }
}

