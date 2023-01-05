//
//  HttpApiManager.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation
import RxSwift
import SwiftyJSON

enum HTTPMethod {
    case get
    case post
    case put
    case patch
    case delete
}

struct HttpAPIManager {
    static var headers: [String: String?] {
        let headers : [String: String?] = [
            "Content-Type": "application/vnd.github+json"
        ]
        return headers
    }
    
    static func callRequest<T>(api: String,
                               method: HTTPMethod,
                               param : Encodable? = nil,
                               body: Encodable? = nil,
                               responseClass:T.Type) -> Observable<T>
    where T: Decodable {
        do {
            guard let url = try self.makeURLWithQueryParams(urlStr: api, param: param) else { return Observable.error(ApiError.inValidUrl) }
            let urlRequest = try URLRequest(url: url, method: method, body: body, headers: headers)
            
            return self.callApi(request: urlRequest, responseClass: responseClass)
        } catch {
            return Observable.error(error)
        }
    }
    
    static func makeURLWithQueryParams(urlStr: String, param: Encodable?) throws -> URL? {
        var queryParams: [String: Any] = [:]
        guard let param = param else { return nil }
        
        do {
            let paramData = try JSONEncoder().encode(param)
            if let paramObject = try JSONSerialization.jsonObject(with: paramData, options: .allowFragments) as? [String: Any] {
                queryParams = paramObject
            }
            
            var urlComponents = URLComponents(string: urlStr)
            var urlQueryItems: [URLQueryItem] = []
            
            for (key, value) in queryParams {
                urlQueryItems.append(URLQueryItem(name: key, value: String(describing: value)))
            }
            
            if urlQueryItems.count > 0 {
                urlComponents?.queryItems = urlQueryItems
            }
            
            guard let url = urlComponents?.url else {
                throw ApiError.inValidUrl
            }
            
            return url
        } catch {
            throw ApiError.encodingError(error)
        }
    }
    
    static func callApi<T>(request : URLRequest, responseClass : T.Type) -> Observable<T>
    where T: Decodable {
        
        return Observable.create { observer -> Disposable in
            log.debug("Request => ", request)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                }
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode,
                   let responseData = data {
                    //log.debug("response => \(JSON(responseData))")
                    switch statusCode {
                    case (200..<300):
                        do {
                            let result = try JSONDecoder().decode(responseClass, from: responseData)
                            observer.onNext(result)
                            observer.onCompleted()
                        } catch {
                            observer.onError(ApiError.decodingError(error))
                        }
                    case (400..<500):
                        if let msg = JSON(responseData)["message"].string {
                            observer.onError(ApiError.client(statusCode, msg))
                        } else {
                            observer.onError(ApiError.client(statusCode, "UnExpected Error"))
                        }
                        
                    default:
                        if let msg = JSON(responseData)["message"].string {
                            observer.onError(ApiError.server(statusCode, msg))
                        } else {
                            observer.onError(ApiError.server(statusCode, "UnExpected Error"))
                        }
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension URLRequest {
    init (url: URL, method: HTTPMethod, body: Encodable?, headers: [String: String?]) throws {
        self.init(url: url)
        self.timeoutInterval = TimeInterval(30)
        
        do {
            let bodyData = try self.makeBody(body: body)
            
            switch method {
            case .get:
                self.httpMethod = "GET"
                
            case .post:
                self.httpMethod = "POST"
                self.httpBody = bodyData
                
            case .put:
                self.httpMethod = "PUT"
                self.httpBody = bodyData
                
            case .patch:
                self.httpMethod = "PATCH"
                self.httpBody = bodyData
                
            case .delete:
                self.httpMethod = "DELETE"
                self.httpBody = bodyData
            }
            
            headers.forEach {
                self.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        } catch {
            throw error
        }
    }
   
    func makeBody(body: Encodable?) throws -> Data? {
        guard let body = body else { return nil }
        
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let bodyData = try jsonEncoder.encode(body)
            
            return bodyData
        } catch {
            throw ApiError.encodingError(error)
        }
    }
}


