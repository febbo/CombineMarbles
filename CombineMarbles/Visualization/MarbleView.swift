//
//  MarbleView.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import SwiftUI

struct MarbleView: View {
    let event: MarbleEvent
    
    var body: some View {
        Circle()
            .fill(event.color)
            .frame(width: 30, height: 30)
            .overlay(
                Text(self.label)
                    .font(.caption)
                    .foregroundColor(.white)
            )
    }
    
    private var label: String {
        switch event.type {
        case .next(let value):
            if let intValue = value as? Int {
                return "\(intValue)"
            } else {
                return "\(value)"
            }
        case .error:
            return "!"
        case .completed:
            return "✓"
        }
    }
}
