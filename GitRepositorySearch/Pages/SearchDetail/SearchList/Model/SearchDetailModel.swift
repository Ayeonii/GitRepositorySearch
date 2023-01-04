//
//  SearchDetailModel.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation
import SwiftyJSON
import UIKit

struct SearchDetailModel {
    var repositories: [SearchDetailCellModel] = []
    
    init(from res: [SeachRepositoryItems]) {
        repositories = res.map { SearchDetailCellModel(from: $0) }
    }
}

struct SearchDetailCellModel {
    var image: String
    var ownerName: String
    var repositoryName: String
    var description: String
    var starCount: Int
    var language: String
    var languageColor: Int
    var linkUrl: String
    
    init(from res: SeachRepositoryItems) {
        self.image = res.owner?.avatarUrl ?? ""
        self.ownerName = res.owner?.login ?? ""
        self.repositoryName = res.name ?? ""
        self.description = res.description ?? ""
        self.starCount = res.stargazersCount ?? 0
        self.language = res.language ?? ""
        self.languageColor = LanguageColor.getColorRgb(language: res.language)
        self.linkUrl = res.htmlUrl ?? ""
    }
}

struct LanguageColor {
    static func getColorRgb(language lang: String?) -> Int {
        let defaultColor = 0xcccccc
        guard let languageName = lang,
              let fileLocation = Bundle.main.path(forResource: "languageColors", ofType: "json") else { return defaultColor }
        let fileUrl = URL(fileURLWithPath: fileLocation)
        
        guard let jsonString = try? String(contentsOf: fileUrl) else { return defaultColor }
        if let data = jsonString.data(using: .utf8),
           let langColor = JSON(data)[languageName].string {
            return Int(langColor, radix: 16) ?? -1
        }
            
        return defaultColor
    }
}
