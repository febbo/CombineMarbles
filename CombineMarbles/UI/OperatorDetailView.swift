//
//  OperatorDetailView.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//


import SwiftUI
import Combine

struct OperatorDetailView: View {
    let `operator`: OperatorDefinition
    @StateObject private var viewModel = OperatorDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(`operator`.description)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text("Visualization")
                        .font(.headline)
                    
                    // Input Stream
                    MarbleStreamView(viewModel: viewModel.inputStream)
                    
                    // Operator indicator
                    HStack {
                        Spacer()
                        Text(`operator`.name)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        Spacer()
                    }
                    
                    // Output Stream
                    MarbleStreamView(viewModel: viewModel.outputStream)
                }
                
                VStack(alignment: .leading) {
                    Text("Code Example")
                        .font(.headline)
                    
                    Text(`operator`.codeExample)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                }
                
                Button("Run Example") {
                    viewModel.runExample(with: `operator`)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .padding()
        }
        .navigationTitle(`operator`.name)
    }
}


