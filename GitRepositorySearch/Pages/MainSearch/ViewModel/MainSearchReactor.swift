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
        case filterRecentList(String?)
        case goToResult(String?)
    }
    
    enum Mutation {
        case setFilteredList([String])
        case setMoveToDetail(String?)
    }
    
    struct State {
        @Pulse var filteredList: [String] = UserDefaultsManager.recentSearchList ?? []
        @Pulse var shouldShowList: Bool = false
        var searchInputText: String?
        var moveToDetailText: String?
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .filterRecentList(let text):
            return filterRecentList(text: text)
            
        case .goToResult(let text):
            self.saveRecent(text: text)
            return .concat([
                .just(.setMoveToDetail(text)),
                .just(.setMoveToDetail(nil))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setFilteredList(let list):
            newState.filteredList = list
            
        case .setMoveToDetail(let text):
            newState.moveToDetailText = text
        }
        
        return newState
    }
}

extension MainSearchReactor {
    func filterRecentList(text: String?) -> Observable<Mutation> {
        let inputText = text ?? ""
        let filteredList = currentState.filteredList.filter{ $0.contains(inputText) }
        return .just(.setFilteredList(filteredList))
    }
    
    func saveRecent(text: String?) {
        guard let text = text else { return }
        var currentSavedRecentList = UserDefaultsManager.recentSearchList ?? []
        currentSavedRecentList.removeAll(where: { $0 == text })
        currentSavedRecentList.insert(text, at: 0)
        UserDefaultsManager.recentSearchList = currentSavedRecentList
    }
}

