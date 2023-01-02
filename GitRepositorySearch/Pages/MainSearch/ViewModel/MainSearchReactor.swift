//
//  MainSearchReactor.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation
import ReactorKit

class MainSearchReactor: Reactor {
    enum Action {
        case filterRecentList(String)
        case goToResult(String?)
    }
    
    enum Mutation {
        case setSearchText(String?)
        case setMoveToDetail(String?)
    }
    
    struct State {
        @Pulse var recentList: [String] = ["zzz", "2222", "3333", "zzz", "2222","3333","zzz", "2222", "3333","zzz", "2222", "3333"]
        @Pulse var filteredList: [String] = ["zzz", "2222", "3333", "zzz", "2222","3333","zzz", "2222", "3333","zzz", "2222", "3333"]
        @Pulse var shouldShowList: Bool = false
        var searchInputText: String?
        var moveToDetailText: String?
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .filterRecentList(let text):
            return .just(.setSearchText(text))
            
        case .goToResult(let text):
            return .concat([
                .just(.setMoveToDetail(text)),
                .just(.setMoveToDetail(nil))
            ])
        }
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSearchText(let text):
            newState.searchInputText = text
            
        case .setMoveToDetail(let text):
            newState.moveToDetailText = text
        }
        
        return newState
    }
}

