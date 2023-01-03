//
//  Scene.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation
import UIKit

enum Scene {
    case mainSearchView(MainSearchReactor)
    case searchDetailView(SearchDetailReactor)
}

extension Scene {
    func instantiate() -> UIViewController {
        switch self {
        case .mainSearchView(let reactor):
            let vc = MainSearchViewController(reactor: reactor)
            vc.bind(reactor: reactor)
            
            return vc
            
        case .searchDetailView(let reactor):
            let vc = SearchDetailViewController(reactor: reactor)
            vc.bind(reactor: reactor)
            
            return vc
        }
    }
}
