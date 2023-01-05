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
        case deleteRecent(String?)
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
            return filterRecentListMutation(text: text)
            
        case .deleteRecent(let text):
            return deleteRecentMutation(text: text)
            
        case .saveRecentText(let text):
            return saveRecentTextMutation(text: text)
            
        case .clearRecentList:
            return clearRecentListMutation()
            
        case .goToResult(let text):
            return goToResultMutation(text: text)
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
    private func saveRecentTextMutation(text: String?) -> Observable<Mutation> {
        guard let text = text else { return .empty() }
        let currentSavedRecentList = makeTargetMovedList(target: text, with: currentState.recentList, to: 0)
        let currentFilterList = makeTargetMovedList(target: text, with: currentState.filteredList, to: 0)
        UserDefaultsManager.recentSearchList = currentSavedRecentList
        
        return .merge(.just(.setFilteredList(currentFilterList)), .just(.setRecentList(currentSavedRecentList)))
    }
    
    private func filterRecentListMutation(text: String?) -> Observable<Mutation> {
        let inputText = text ?? ""
        if inputText.isEmpty { return .just(.setFilteredList(currentState.recentList)) }
        let filteredList = currentState.recentList.filter { $0.contains(inputText) }
        
        return .just(.setFilteredList(filteredList))
    }
    
    private func deleteRecentMutation(text: String?) -> Observable<Mutation> {
        guard let text = text else { return .empty() }
        let currentSavedRecentList = makeTargetRemovedList(target: text, with: currentState.recentList)
        let currentFilterList = makeTargetRemovedList(target: text, with: currentState.filteredList)
        UserDefaultsManager.recentSearchList = currentSavedRecentList
        
        return .merge(.just(.setFilteredList(currentFilterList)), .just(.setRecentList(currentSavedRecentList)))
    }
    
    private func clearRecentListMutation() -> Observable<Mutation> {
        UserDefaultsManager.recentSearchList = []
        return .merge(.just(.setRecentList([])), .just(.setFilteredList([])))
    }
    
    private func goToResultMutation(text: String?) -> Observable<Mutation> {
        return .concat([
            .just(.setMoveToDetail(text)),
            .just(.setMoveToDetail(nil))
        ])
    }
}

extension MainSearchReactor {
    func makeTargetMovedList(target: String, with list: [String], to index: Int) -> [String] {
        var recentList = list
        recentList.removeAll(where: { $0 == target })
        recentList.insert(target, at: index)
        return recentList
    }
    
    func makeTargetRemovedList(target: String, with list: [String]) -> [String] {
        var recentList = currentState.filteredList
        recentList.removeAll(where: { $0 == target })
        return recentList
    }
}
