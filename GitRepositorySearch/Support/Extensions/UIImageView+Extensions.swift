//
//  UIImageView+Extensions.swift
//  GitRepositorySearch
//
//  Created by Ayeon on 2023/01/03.
//

import UIKit
import RxSwift

extension UIImageView {
    
    func downloadImage(url: String, width: CGFloat?, placeholder: UIImage? = nil) -> Disposable? {
        self.image = placeholder
        guard let imageUrl: URL = URL(string: url) else { return nil }
        
        return ImageCache.shared.load(url: imageUrl as NSURL)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] image in
                guard let self = self else { return }
                let resizedImage = (width == nil) ? image : image?.resize(newWidth: width!)
                
                UIView.transition(with: self,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: { self.image = resizedImage },
                              completion: nil)
            }, onCompleted: {
                //log.debug("completed")
            }, onDisposed: {
                //log.debug("disposed")
            })
    }
}
