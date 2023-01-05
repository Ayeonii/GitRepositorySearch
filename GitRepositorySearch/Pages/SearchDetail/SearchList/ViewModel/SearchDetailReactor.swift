//
//  SearchDetailReactor.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation
import ReactorKit

class SearchDetailReactor: Reactor {
    let perPage = 30
    var page = 1
    var totalRepositoryCount: Int = 0
    var isLastPage: Bool {
        return totalRepositoryCount <= page * perPage
    }
    
    enum Action {
        case fetchRepository
        case showMenu
        case sortOption(SearchRepositorySortType)
        case orderOption(SearchRepositoryOrderType)
        case moveToLink(String)
    }
    
    enum Mutation {
        case setRepositories([SearchDetailCellModel])
        case setPagingRepoIndex([Int])
        case setFetching(Bool)
        case setReload(Bool)
        case setEndPage(Bool)
        case setShowMenu(Bool)
        case setSortOption(SearchRepositorySortType)
        case setMoveLink(String?)
    }
    
    struct State {
        let searchText: String
        var repositories: [SearchDetailCellModel]?
        @Pulse var pagingRows: [Int] = []
        var isFetching: Bool = false
        var shouldReload: Bool = false
        var shouldShowMenu: Bool = false
        var endPaging: Bool = false
        var sortingOption: SearchRepositorySortType = .default
        var moveLink: String?
    }
    
    let initialState: State
    
    init(searchText: String) {
        initialState = State(searchText: searchText)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchRepository:
            return fetchRepositoriesMutation(text: currentState.searchText)
            
        case .showMenu:
            return showMenuMutation()
            
        case .sortOption(let option):
            resetPage()
            return .merge(
                .just(.setSortOption(option)),
                fetchRepositoriesMutation(text: currentState.searchText, sort: option)
            )
            
        case .orderOption(let option):
            resetPage()
            return fetchRepositoriesMutation(text: currentState.searchText, sort: currentState.sortingOption, order: option)
            
        case .moveToLink(let link):
            return moveToLinkMutation(link)
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
            
        case .setSortOption(let sortOption):
            newState.sortingOption = sortOption
            
        case .setMoveLink(let link):
            newState.moveLink = link
        }
        
        return newState
    }
}

extension SearchDetailReactor {
    
    private func fetchRepositoriesMutation(text: String, sort: SearchRepositorySortType? = nil, order: SearchRepositoryOrderType? = nil) -> Observable<Mutation> {
        
        return .concat([
            .just(.setFetching(true)),
            requestRepositoriesMutation(text, sort, order),
            .just(.setFetching(false))
        ])
    }
    
    private func requestRepositoriesMutation(_ text: String, _ sort: SearchRepositorySortType?, _ order: SearchRepositoryOrderType?) -> Observable<Mutation> {
        guard !currentState.endPaging else { return .empty() }
        
        return SearchApi.fetchRepositoryWithText(text: text,
                                                 sort: sort,
                                                 order: order,
                                                 perPage: perPage,
                                                 page: page)
        .flatMap { [weak self] res -> Observable<Mutation> in
            guard let self = self,
                  let repos = res.repositories,
                  res.incompleteResults == false else { return .empty() }
            
            self.totalRepositoryCount = res.totalCount ?? 0
            let newRepos = SearchDetailModel(from: repos).repositories
            
            return self.makeRepositoriesByPagingMutation(newRepos: newRepos)
        }
        .catch {
            log.error($0)
            return .empty()
        }
    }
    
    private func makeRepositoriesByPagingMutation(newRepos: [SearchDetailCellModel]) -> Observable<Mutation> {
        let isLast = self.isLastPage
        let isPaging = self.page > 1
        addPage()
        
        if isPaging {
            let lastRepos = currentState.repositories ?? []
            let lastRepoCount = lastRepos.count
            let pagingRepos = Array(lastRepoCount..<(lastRepoCount + newRepos.count))
            return .concat([
                .just(.setEndPage(isLast)),
                .just(.setRepositories(lastRepos + newRepos)),
                .just(.setPagingRepoIndex(pagingRepos))
            ])
        }
        
        return .concat([
            .just(.setEndPage(isLast)),
            .just(.setRepositories(newRepos)),
            reloadAllMutation()
        ])
    }
    
    func reloadAllMutation() -> Observable<Mutation> {
        return .concat([
            .just(.setReload(true)),
            .just(.setReload(false))
        ])
    }
    
    func showMenuMutation() -> Observable<Mutation> {
        return .concat([
            .just(.setShowMenu(true)),
            .just(.setShowMenu(false))
        ])
    }
    
    func moveToLinkMutation(_ link: String?) -> Observable<Mutation> {
        return .concat([
            .just(.setMoveLink(link)),
            .just(.setMoveLink(nil))
        ])
    }
}

extension SearchDetailReactor {
    func resetPage() {
        self.page = 1
    }
    
    func addPage() {
        self.page += 1
    }
}
