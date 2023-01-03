//
//  SearchApi.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation
import RxSwift

struct SearchApi {
    enum EndPoint {
        case repositories
    
        var url: String {
            let url = "https://api.github.com/search"
            switch self {
            case .repositories:
                return url + "/repositories"
            }
        }
    }
}

extension SearchApi {
    static func fetchRepositoryWithText(text: String, sort: SearchRepositorySortType?, order: SearchRepositoryOrderType?, perPage: Int, page: Int) -> Observable<SearchRepositoryCodable> {
        
        let apiUrl = EndPoint.repositories.url
        
        let params = SearchRepositoryParams(q: text, sort: sort?.rawValue, order: order?.rawValue, perPage: perPage, page: page)
        
        return HttpAPIManager.callRequest(api: apiUrl,
                                          method: .get,
                                          param: params,
                                          responseClass: SearchRepositoryCodable.self)
    }
}

