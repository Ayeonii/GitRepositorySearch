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
        case deleteRecent(String)
        case clearRecentList
        case saveRecentText(String)
    }
    
    enum Mutation {
        case setRecentList([String])
        case setFilteredList([String])
        case setMoveToDetail(String?)
    }
    
    struct State {
        var recentList: [String]
        @Pulse var filteredList: [String]
        @Pulse var shouldShowList: Bool = false
        var searchInputText: String?
        var moveToDetailText: String?
    }
    
    let initialState: State
    
    init() {
        let userRecentSearchList = UserDefaultsManager.recentSearchList ?? []
        initialState = State(recentList: userRecentSearchList,
                             filteredList: userRecentSearchList)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
       
        case .filterRecentList(let text):
            return filterRecentList(text: text)
            
        case .goToResult(let text):
            return goToResult(text: text)
            
        case .clearRecentList:
            return clearAllRecent()
            
        case .deleteRecent(let text):
            return deleteRecentItem(text: text)
            
        case .saveRecentText(let text):
            return saveRecent(text: text)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setRecentList(let list):
            newState.recentList = list
            
        case .setFilteredList(let list):
            newState.filteredList = list
            
        case .setMoveToDetail(let text):
            newState.moveToDetailText = text
        }
        
        return newState
    }
}

extension MainSearchReactor {
    func saveRecent(text: String?) -> Observable<Mutation> {
        guard let text = text else { return .empty() }
        var currentSavedRecentList = currentState.recentList
        currentSavedRecentList.removeAll(where: { $0 == text })
        currentSavedRecentList.insert(text, at: 0)
        UserDefaultsManager.recentSearchList = currentSavedRecentList
        
        let currentFilterList = [text] + currentState.filteredList
        return .merge(.just(.setFilteredList(currentFilterList)), .just(.setRecentList(currentSavedRecentList)))
    }
    
    func filterRecentList(text: String?) -> Observable<Mutation> {
        let inputText = text ?? ""
        if inputText.isEmpty { return .just(.setFilteredList(currentState.recentList)) }
        
        let filteredList = currentState.recentList.filter{ $0.contains(inputText) }
        log.debug(filteredList)
        return .just(.setFilteredList(filteredList))
    }
    
    func clearAllRecent() -> Observable<Mutation> {
        UserDefaultsManager.recentSearchList = []
        
        return .concat([
            .just(.setRecentList([])),
            .just(.setFilteredList([]))
        ])
    }
    
    func deleteRecentItem(text: String) -> Observable<Mutation> {
        var currentSavedRecentList = currentState.recentList
        currentSavedRecentList.removeAll(where: { $0 == text })
        UserDefaultsManager.recentSearchList = currentSavedRecentList
        
        var currentFilterList = currentState.filteredList
        currentFilterList.removeAll(where: { $0 == text })
        
        return .merge(.just(.setFilteredList(currentFilterList)), .just(.setRecentList(currentSavedRecentList)))
    }
    
    func goToResult(text: String?) -> Observable<Mutation> {
        return .concat([
            .just(.setMoveToDetail(text)),
            .just(.setMoveToDetail(nil))
        ])
    }
}

