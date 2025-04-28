//
//  ContentView.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OperatorsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(OperatorCategory.allCases, id: \.self) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(viewModel.operators.filter { $0.category == category }) { op in
                            NavigationLink(destination: OperatorDetailView(operator: op)) {
                                Text(op.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Combine Marbles")
        }
    }
}
