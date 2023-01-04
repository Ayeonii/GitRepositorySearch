//
//  SearchOptionsModel.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/04.
//

import Foundation

enum SearchOptionsType: String {
    case sort = "Sort"
    case order = "Order"
    
    func getOptionList() -> [String] {
        switch self {
        case .sort:
            return SearchRepositorySortType.allCases.map { $0.rawValue }
            
        case .order:
            return SearchRepositoryOrderType.allCases.map { $0.rawValue }
        }
    }
}
