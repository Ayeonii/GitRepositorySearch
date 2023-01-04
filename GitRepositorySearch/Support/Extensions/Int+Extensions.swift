//
//  Int+Extensions.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/04.
//

import Foundation

extension Int {
    func toDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from : NSNumber(value: self)) ?? "0"
    }
}
