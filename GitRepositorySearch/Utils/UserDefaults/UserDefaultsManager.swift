//
//  UserDefaultsManager.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation

struct UserDefaultsManager {
    @UserDefaultsWrapper(key: "RecentSearchList", value: nil)
    static var recentSearchList: [SearchResultItemModel]?
}

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    private let key: String
    private let value: T?
    
    init(key: String, value: T?) {
        self.key = key
        self.value = value
    }
    
    var wrappedValue: T? {
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let lodedObejct = try? decoder.decode(T.self, from: savedData) {
                    return lodedObejct
                }
            }
            return value
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: key)
            }
        }
    }
}
