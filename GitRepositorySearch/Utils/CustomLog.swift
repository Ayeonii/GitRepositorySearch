//
//  MyLog.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation

struct CustomLog {
    static func error(_ object: Any?..., filename: String = #file, line: Int = #line, funcName: String = #function) {
        #if DEBUG
            var msg: String = ""
            object.forEach {
                if let obj = $0 {
                    msg += "\(obj)"
                } else {
                    msg += "nil"
                }
            }
            print("❗️❗️😰😰 ERROR \(Date()) \(filename.components(separatedBy: "/").last ?? "")(\(line)) - \(funcName) : \(msg)")
        #endif
    }

    static func debug(_ object: Any?..., filename: String = #file, line: Int = #line, funcName: String = #function) {
        #if DEBUG
            var msg: String = ""
            object.forEach {
                if let obj = $0 {
                    msg += "\(obj)"
                } else {
                    msg += "nil"
                }
            }
            print("✏️✏️✏️\(Date()) \(filename.components(separatedBy: "/").last ?? "")(\(line)) - \(funcName) : \(msg)")
        #endif
    }

    static func deinitLog(filename: String = #file, line: Int = #line, funcName: String = #function) {
        #if DEBUG
            print("\(Date()) \(filename.components(separatedBy: "/").last ?? "") --> Deinit👍👍")
        #endif
    }
}


