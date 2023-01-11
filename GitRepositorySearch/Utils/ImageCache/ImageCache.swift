//
//  ImageCache.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import Foundation
import UIKit
import RxSwift
import Then

public protocol ImageItem {
    var image: UIImage? { get set }
    var imageUrl: URL { get }
    var identifier: String { get }
}

public class ImageCache {
    public static let shared = ImageCache()
    
    private init() { }
    
    private let cacheImages = NSCache<NSURL, UIImage>().then {
        $0.totalCostLimit = 50 * 1024 * 1024
    }
    
    private final func image(url: NSURL) -> UIImage? {
        return cacheImages.object(forKey: url)
    }
    
    final func load(url: NSURL) -> Observable<UIImage?> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            if let cachedImage = self.image(url: url) {
                observer.onNext(cachedImage)
                observer.onCompleted()
            }
            
            let urlSession = URLSession(configuration: .ephemeral)
            let task = urlSession.dataTask(with: url as URL) { data, response, error in
                if let error = error {
                    observer.onError(ApiError.imageFetchFail(error.localizedDescription))
                }
                
                if let responseData = data,
                   let image = UIImage(data: responseData) {
                    self.cacheImages.setObject(image, forKey: url, cost: responseData.count)
                    observer.onNext(image)
                    observer.onCompleted()
                } else {
                    observer.onError(ApiError.convertImageFail)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    final func clearCache() {
        cacheImages.removeAllObjects()
    }
}
