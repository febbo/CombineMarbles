//
//  Untitled.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import SwiftUI
import Combine

class OperatorDetailViewModel: ObservableObject {
    @Published var inputStream = MarbleStreamViewModel(title: "Input")
    @Published var outputStream = MarbleStreamViewModel(title: "Output")
    
    private var cancellables = Set<AnyCancellable>()
    
    func runExample(with operator: OperatorDefinition) {

        inputStream.reset()
        outputStream.reset()
        
        cancellables.removeAll()
        
        `operator`.inputStrategy.apply(to: inputStream)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Apply operator
            let inputPublisher = self.inputStream.asPublisher()
            let outputPublisher = `operator`.apply([inputPublisher])
            
            // Output values
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
}
