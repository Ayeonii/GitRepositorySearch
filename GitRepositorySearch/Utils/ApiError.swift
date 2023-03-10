//
//  ApiError.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation

enum ApiError: Error {
    case decodingError(Error)
    case encodingError(Error)
    case inValidUrl
    case imageFetchFail(String?)
    case convertImageFail
    case server(Int, String?)
    case client(Int, String?)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodingError(let error):
            return "description: " + error.localizedDescription
        case .encodingError(let error):
            return "description: " + error.localizedDescription
        case .inValidUrl:
            return "description: Invalid URL"
        case .imageFetchFail(let msg):
            return "description: " + (msg ?? "")
        case .convertImageFail:
            return "description: Converting To Image Fail"
        case .server(_, let msg),
             .client(_, let msg):
            return "description: " + (msg ?? "")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .decodingError:
            return "Check Decoding Type"
        case .encodingError:
            return "Check Encoding Type"
        case .inValidUrl:
            return "Check URL"
        case .imageFetchFail:
            return "Check Image URL"
        case .convertImageFail:
            return "Check Image Data"
        case .server,
             .client:
            return "Retry"
        }
    }
}

extension ApiError: CustomNSError {
    static var errorDomain: String {
        return "ApiError"
    }
    
    var errorCode: Int {
        switch self {
        case .server(let statusCode, _),
                .client(let statusCode, _):
            return statusCode
        default:
            return -1
        }
    }
    
    var errorUserInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: errorDescription ?? "",
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
    }
    
    var nsError: NSError {
        return NSError(apiError: self)
    }
}
