//
//  InputGenerationStrategy.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 28/04/25.
//

import SwiftUI
import Combine

enum InputGenerationStrategy {
    case random                  // Input random standard
    case optionals               // Input random with nil values
    case delayed                 // Delayed Inputs
    case custom((MarbleStreamViewModel) -> Void)  // Personalized input strategy
    
    func apply(to streamViewModel: MarbleStreamViewModel) {
        switch self {
        case .random:
            streamViewModel.generateRandomEvents(count: 5)
            
        case .optionals:
            streamViewModel.reset()
            
            //Number of events to generate
            let count = 5
            let timelineDuration = streamViewModel.timelineDuration
            let interval = (timelineDuration * 0.8) / Double(count)
            let nilProbability = 0.3
            
            for i in 0..<count {
                let time = Double(i) * interval + 0.5
                streamViewModel.setCurrentTime(time)
                
                // Generate a random number of nil
                if Double.random(in: 0...1) < nilProbability {
                    streamViewModel.addEvent(.next("nil"))
                } else {
                    let randomValue = Int.random(in: 10...100)
                    streamViewModel.addEvent(.next(randomValue))
                }
            }
            
            streamViewModel.setCurrentTime(timelineDuration * 0.9)
            streamViewModel.addEvent(.completed)
            
        case .custom(let generator):
            generator(streamViewModel)
        case .delayed:
            // Implementazione per eventi ritardati utili per operatori di timing
            streamViewModel.reset()
            let timelineDuration = streamViewModel.timelineDuration
            
            // Genera eventi con spaziatura non uniforme
            let times: [Double] = [0.2, 0.3, 0.6, 0.9]
            
            for (i, time) in times.enumerated() {
                streamViewModel.setCurrentTime(time * timelineDuration)
                let value = (i + 1) * 10
                streamViewModel.addEvent(.next(value))
            }
            
            streamViewModel.setCurrentTime(timelineDuration * 0.95)
            streamViewModel.addEvent(.completed)
        }
    }
}
