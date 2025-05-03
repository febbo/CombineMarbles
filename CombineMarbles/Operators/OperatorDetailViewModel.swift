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
    
    func runExample(with operator: OperatorDefinition) {
        setupInputStreams(for: `operator`)
        outputStream.reset()
        cancellables.removeAll()
        
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
            
            outputPublisher
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else { return }
                        
                        switch completion {
                        case .finished:
                            self.outputStream.setCurrentTime(self.outputStream.timelineDuration * 0.9)
                            self.outputStream.addEvent(.completed)
                        case .failure(let error):
                            self.outputStream.setCurrentTime(self.outputStream.timelineDuration * 0.9)
                            self.outputStream.addEvent(.error(error))
                        }
                    },
                    receiveValue: { [weak self] value in
                        guard let self = self else { return }
                        
                        let currentOutputTime = self.outputStream.events.isEmpty ? 1.0 : (self.outputStream.currentTime + 1.5)
                        self.outputStream.setCurrentTime(currentOutputTime)
                        
                        self.outputStream.addEvent(.next(value))
                    }
                )
                .store(in: &self.cancellables)
        }
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
