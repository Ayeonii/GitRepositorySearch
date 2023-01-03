//
//  SearchDetailModel.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation

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
    var linkUrl: String
    
    init(from res: SeachRepositoryItems) {
        self.image = res.owner?.avatarUrl ?? ""
        self.ownerName = res.owner?.login ?? ""
        self.repositoryName = res.name ?? ""
        self.description = res.description ?? ""
        self.starCount = res.stargazersCount ?? 0
        self.language = res.language ?? ""
        self.linkUrl = res.htmlUrl ?? ""
    }
}
