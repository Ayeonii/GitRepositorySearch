//
//  NSError+Extensions.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation

extension NSError {
    convenience init(apiError: ApiError) {
        self.init(domain: ApiError.errorDomain, code: apiError.errorCode, userInfo: apiError.errorUserInfo)
    }
}
