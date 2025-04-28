//
//  OperatorsViewModel.swift
//  CombineMarbles
//
//  Created by Leonardo Febbo on 24/03/25.
//

import Combine

class OperatorsViewModel: ObservableObject {
    @Published var operators: [OperatorDefinition]
    
    init() {
        self.operators = OperatorLibrary.shared.operators
    }
}
