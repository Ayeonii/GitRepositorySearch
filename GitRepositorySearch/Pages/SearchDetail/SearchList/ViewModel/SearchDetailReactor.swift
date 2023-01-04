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
    var totalRepositoryCount: Int = 0
    var isLastPage: Bool {
        return totalRepositoryCount <= page * perPage
    }
    
    enum Action {
        case fetchRepository
        case showMenu
    }
    
    enum Mutation {
        case setRepositories([SearchDetailCellModel])
        case setPagingRepoIndex([Int])
        case setFetching(Bool)
        case setReload(Bool)
        case setEndPage(Bool)
        case setShowMenu(Bool)
    }
    
    struct State {
        let searchText: String
        var repositories: [SearchDetailCellModel]?
        @Pulse var pagingRows: [Int] = []
        var isFetching: Bool = false
        var shouldReload: Bool = false
        var endPaging: Bool = false
        var shouldShowMenu: Bool = false
    }
    
    let initialState: State
    
    init(searchText: String) {
        initialState = State(searchText: searchText)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRepository:
            return .concat([
                .just(.setFetching(true)),
                fetchRepositories(text: currentState.searchText),
                .just(.setFetching(false))
            ])
            
        case .showMenu:
            return showMenuAction()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setRepositories(let repositories):
            newState.repositories = repositories
            
        case .setPagingRepoIndex(let indexs):
            newState.pagingRows = indexs
            
        case .setFetching(let isFetching):
            newState.isFetching = isFetching
            
        case .setReload(let shouldReload):
            newState.shouldReload = shouldReload
            
        case .setEndPage(let isEnd):
            newState.endPaging = isEnd
            
        case .setShowMenu(let shouldShow):
            newState.shouldShowMenu = shouldShow
        }
        
        return newState
    }
}

extension SearchDetailReactor {
    private func fetchRepositories(text: String, sort: SearchRepositorySortType? = nil, order: SearchRepositoryOrderType? = nil) -> Observable<Mutation> {
        guard !currentState.endPaging else { return .empty() }
        
        return SearchApi.fetchRepositoryWithText(text: text,
                                                 sort: sort,
                                                 order: order,
                                                 perPage: perPage,
                                                 page: page)
        .flatMap {[weak self] res -> Observable<Mutation> in
            guard let self = self,
                  let repos = res.repositories,
                  res.incompleteResults == false else { return .empty() }
            
            self.totalRepositoryCount = res.totalCount ?? 0
            
            let lastRepos = self.currentState.repositories ?? []
            let newRepos = SearchDetailModel(from: repos).repositories
            
            return self.setRepositoryByPaging(lastRepos: lastRepos, newRepos: newRepos)
        }
        .catch {
            log.error($0)
            return .empty()
        }
    }
    
    private func setRepositoryByPaging(lastRepos: [SearchDetailCellModel], newRepos: [SearchDetailCellModel]) -> Observable<Mutation> {
        let isLast = self.isLastPage
        let isPaging = self.page > 1
        self.page += 1
        
        if isPaging {
            let lastRepoCount = lastRepos.count
            let pagingRepos = Array(lastRepoCount..<(lastRepoCount + newRepos.count))
            return .concat([
                .just(.setEndPage(isLast)),
                .just(.setPagingRepoIndex(pagingRepos)),
                .just(.setRepositories(lastRepos + newRepos))
            ])
        }
        
        return .concat([
            .just(.setEndPage(isLast)),
            .just(.setRepositories(lastRepos + newRepos)),
            self.reloadAll()
        ])
    }
}

extension SearchDetailReactor {
    
    func reloadAll() -> Observable<Mutation> {
        return .concat([
            .just(.setReload(true)),
            .just(.setReload(false))
        ])
    }
    
    func showMenuAction() -> Observable<Mutation> {
        return .concat([
            .just(.setShowMenu(true)),
            .just(.setShowMenu(false))
        ])
    }
}

