//
//  HttpApiManager.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/02.
//

import Foundation
import RxSwift

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
            "Content-Type": "application/json"
        ]
        return headers
    }
    
    static func callRequest<T, B, P>(api: String,
                                     method: HTTPMethod,
                                     param : P? = nil,
                                     body: B? = nil,
                                     responseClass:T.Type) -> Observable<T>
    where T: Decodable, P: Encodable, B: Encodable {
        do {
            let url = try self.makeURLWithQueryParams(url: api, param: param)
            let urlRequest = try URLRequest(url: url, method: method, body: body, headers: headers)
            
            return self.callApi(request: urlRequest, responseClass: responseClass)
            
        } catch {
            return Observable.error(error)
        }
    }
    
    static func makeURLWithQueryParams(url: String, param: Encodable) throws -> URL {
        var queryParams : [String : Any] = [:]
        
        do {
            let paramData = try JSONEncoder().encode(param)
            if let paramObject = try JSONSerialization.jsonObject(with: paramData, options: .allowFragments) as? [String: Any] {
                queryParams = paramObject
            }
            
            var urlComponents = URLComponents(string: url)
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
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                }
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode,
                   let responseData = data {
                    
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
                        observer.onError(ApiError.client(statusCode, "Client has problem."))
                    default:
                        observer.onError(ApiError.server(statusCode, "Sever has problem."))
                    }
                }
            }
            .resume()
            
            return Disposables.create()
        }
    }
}


extension URLRequest {
    init<Body: Encodable> (url: URL, method: HTTPMethod, body: Body, headers: [String: String?]) throws {
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
   
    
    func makeBody(body: Encodable) throws -> Data? {
        var bodyParam: [String: Any] = [:]
        do {
            let bodyData = try JSONEncoder().encode(body)
            if let bodyObject = try JSONSerialization.jsonObject(with: bodyData, options: .allowFragments) as? [String: Any] {
                bodyParam = bodyObject
            }
        } catch {
            throw ApiError.encodingError(error)
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: bodyParam, options: JSONSerialization.WritingOptions.prettyPrinted) {
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            return json?.data(using: String.Encoding.utf8.rawValue)
        } else {
            return nil
        }
    }
}


