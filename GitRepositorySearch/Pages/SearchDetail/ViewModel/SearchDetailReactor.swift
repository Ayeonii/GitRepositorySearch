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
        case fetchRepository
    }
    
    enum Mutation {
        case setRepositories([SearchDetailCellModel])
        case setPaginRepoIndex([Int])
    }
    
    struct State {
        let searchText: String
        var repositories: [SearchDetailCellModel] = []
        @Pulse var pagingRows: [Int] = []
    }
    
    let initialState: State
    
    init(searchText: String) {
        initialState = State(searchText: searchText)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRepository:
            return fetchRepositories(text: currentState.searchText)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setRepositories(let repositories):
            newState.repositories = repositories
            
        case .setPaginRepoIndex(let indexs):
            newState.pagingRows = indexs
        }
        
        return newState
    }
}

extension SearchDetailReactor {
    
    func fetchRepositories(text: String, sort: SearchRepositorySortType? = nil, order: SearchRepositoryOrderType? = nil) -> Observable<Mutation> {
        
        SearchApi.fetchRepositoryWithText(text: text,
                                          sort: sort,
                                          order: order,
                                          perPage: perPage,
                                          page: page)
        .flatMap {[weak self] res -> Observable<Mutation> in
            guard let self = self,
                  let repos = res.repositories,
                  res.incompleteResults == false else { return .empty() }
            
            let isPaging = self.page > 1
            self.page += 1
            
            let lastRepos = self.currentState.repositories
            let newRepos = SearchDetailModel(from: repos).repositories
            
            if isPaging {
                let lastRepoCount = lastRepos.count
                let pagingRepos = Array(lastRepoCount..<(lastRepoCount + newRepos.count))
                return .concat([
                    .just(.setPaginRepoIndex(pagingRepos)),
                    .just(.setRepositories(lastRepos + newRepos))
                ])
            }

            return .just(.setRepositories(lastRepos + newRepos))
        }
        .catch {
            log.error($0)
            return .empty()
        }
    }
}
