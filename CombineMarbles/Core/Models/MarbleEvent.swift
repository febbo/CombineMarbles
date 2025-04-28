//
//  MarbleEvent.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import Foundation
import SwiftUI

enum MarbleEventType {
    case next(Any)
    case error(Error)
    case completed
}

struct MarbleEvent: Identifiable {
    let id = UUID()
    let position: TimeInterval // Posizione temporale fittizia (da 0 a timelineDuration)
    let type: MarbleEventType
    
    var color: Color {
        switch type {
        case .next: return .blue
        case .error: return .red
        case .completed: return .gray
        }
    }
}
