//
//  SearchDetailReactor.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation
import ReactorKit

class SearchDetailReactor: Reactor {
    var page = 1
    let perPage = 30
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let searchText: String
        var repositories: [SearchDetailCellModel] = []
    }
    
    let initialState: State
    
    init(searchText: String) {
        initialState = State(searchText: searchText)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        }
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}

extension SearchDetailReactor {
    
    func fetchRepositories(text: String, sort: SearchRepositorySortType?, order: SearchRepositoryOrderType?) -> Observable<Mutation> {
        
        SearchApi.fetchRepositoryWithText(text: text,
                                          sort: sort,
                                          order: order,
                                          perPage: self.perPage,
                                          page: self.page)
        .flatMap { res -> Observable<Mutation> in
            return .empty()
        }
        .catch {
            log.error($0)
            return .empty()
        }
    }
}
