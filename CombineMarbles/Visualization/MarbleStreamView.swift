//
//  MarbleStreamView.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import SwiftUI
import Combine

struct MarbleStreamView: View {
    @ObservedObject var viewModel: MarbleStreamViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.headline)
            
            ZStack(alignment: .leading) {
                // Timeline line (con larghezza fissa)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: viewModel.timelineWidth, height: 2)
                
                // Bordi della timeline
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2, height: 10)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2, height: 10)
                    .offset(x: viewModel.timelineWidth)
                
                // Marbles
                ForEach(viewModel.events) { event in
                    MarbleView(event: event)
                        .position(x: viewModel.xPositionForEvent(event), y: 0)
                }
            }
            .frame(height: 50)
            .padding(.vertical, 8)
        }
        .padding()
    }
}


