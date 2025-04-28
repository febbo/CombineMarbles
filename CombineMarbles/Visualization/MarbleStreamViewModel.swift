//
//  MarbleStreamViewModel.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import Combine
import Foundation

class MarbleStreamViewModel: ObservableObject {
    let title: String
    
    // Tempo fittizio invece di timestamp reali
    var startTime: TimeInterval = 0
    var currentTime: TimeInterval = 0
    
    // Impostazioni di visualizzazione
    let timelineDuration: TimeInterval = 10.0 // 10 secondi totali nella timeline
    let timelineWidth: CGFloat = 300 // Larghezza fisica della timeline in punti
    
    @Published var events: [MarbleEvent] = []
    
    init(title: String) {
        self.title = title
    }
    
    func reset() {
        events = []
        currentTime = 0
    }
    
    // Metodo pubblico per impostare il tempo corrente
    func setCurrentTime(_ newTime: TimeInterval) {
        currentTime = min(max(0, newTime), timelineDuration) // Limita tra 0 e timelineDuration
    }
    
    func addEvent(_ type: MarbleEventType) {
        // Crea un evento con timestamp fittizio
        let event = MarbleEvent(position: currentTime, type: type)
        DispatchQueue.main.async {
            self.events.append(event)
        }
    }
    
    func generateRandomEvents(count: Int) {
        reset()
        
        // Distribuisce gli eventi in modo uniforme lungo la timeline
        let interval = (timelineDuration * 0.8) / Double(count)
        
        for i in 0..<count {
            let time = Double(i) * interval + 0.5 // Inizia da 0.5 per spaziatura
            currentTime = time
            
            let randomValue = Int.random(in: 1...100)
            addEvent(.next(randomValue))
        }
        
        // Aggiunge il completamento alla fine
        currentTime = timelineDuration * 0.9
        addEvent(.completed)
    }
    
    // Calcola la posizione X di un evento sulla timeline
    func xPositionForEvent(_ event: MarbleEvent) -> CGFloat {
        return (CGFloat(event.position) / CGFloat(timelineDuration)) * timelineWidth
    }
        
    func asPublisher() -> AnyPublisher<Any, Error> {
        let subject = PassthroughSubject<Any, Error>()
        
        // Pianifica l'emissione dei valori usando il tempo fittizio per le proporzioni
        let baseDelay: TimeInterval = 0.05
        
        for event in events {
            if case .next(let value) = event.type {
                let normalizedPosition = event.position / timelineDuration
                let delay = baseDelay + normalizedPosition * 2.0 // Scala 0-10 a 0-2 secondi reali
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    subject.send(value)
                }
            }
        }
        
        // Completa il publisher dopo che tutti gli eventi sono stati emessi
        if let lastEvent = events.last {
            let normalizedPosition = lastEvent.position / timelineDuration
            let finalDelay = baseDelay + normalizedPosition * 2.0 + 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + finalDelay) {
                subject.send(completion: .finished)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
}
