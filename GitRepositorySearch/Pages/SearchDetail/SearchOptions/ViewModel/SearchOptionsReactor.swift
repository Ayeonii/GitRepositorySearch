//
//  SearchOptionsReactor.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/04.
//

import Foundation
import ReactorKit

class SearchOptionsReactor: Reactor {
    let disposeBag = DisposeBag()
    
    let viewType: SearchOptionsType
    
    enum Action {
        case selectOption(String)
        case closeView
    }
    
    enum Mutation {
        case setCloseView(Bool)
        case setSortOption(SearchRepositorySortType?)
        case setOrderOption(SearchRepositoryOrderType?)
    }
    
    struct State {
        @Pulse var optionList: [String]
        var selectedSortOption: SearchRepositorySortType?
        var selectedOrderOption: SearchRepositoryOrderType?
        var shouldCloseView: Bool = false
    }
    
    let initialState: State
    
    init(viewType: SearchOptionsType) {
        self.viewType = viewType
        self.initialState = State(optionList: viewType.getOptionList())
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .closeView:
            return closeViewMutation()
            
        case .selectOption(let option):
            return selectOptionMutation(option)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCloseView(let shouldClose):
            newState.shouldCloseView = shouldClose
            
        case .setSortOption(let sortOption):
            newState.selectedSortOption = sortOption
            
        case .setOrderOption(let orderOption):
            newState.selectedOrderOption = orderOption
        }
        
        return newState
    }
}

extension SearchOptionsReactor {
    func selectOptionMutation(_ option: String) -> Observable<Mutation> {
        switch viewType {
        case .sort:
            guard let type = SearchRepositorySortType(rawValue: option) else { return .empty() }
            return .concat([
                .just(.setSortOption(type)),
                .just(.setSortOption(nil)),
                closeViewMutation()
            ])
            
        case .order:
            guard let type = SearchRepositoryOrderType(rawValue: option) else { return .empty() }
            return .concat([
                .just(.setOrderOption(type)),
                .just(.setOrderOption(nil)),
                closeViewMutation()
            ])
        }
    }
    
    func closeViewMutation() -> Observable<Mutation> {
        return .concat([
            .just(.setCloseView(true)),
            .just(.setCloseView(false))
        ])
    }
}
