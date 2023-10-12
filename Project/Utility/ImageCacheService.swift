//
//  ImageCacheService.swift
//  Project
//
//  Created by rayeon lee on 2023/08/03.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageCacheService {
    
    static let shared = ImageCacheService()
    private let memoryCache = ImageCache()
    private let diskCache = DiskCache.default
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    
    private init() { }
    
    func loadImage(from urlString: String) -> Observable<UIImage?> {
        guard let url = URL(string: urlString) else {
            return Observable.empty()
        }
        
        // 1. Lookup NSCache
        if let image = self.checkMemory(url) {
            return Observable.just(image)
        }
        
        // 2. Lookup DiskCache
        if let image = self.checkDisk(url) {
            return Observable.just(image)
        }
        
        // 3. Load Image
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { UIImage(data: $0) }
            .filter{ $0 != nil }
            .map { $0! }
            .map {
                guard let data = $0.pngData() else { return nil }
                self.diskCache.store(data, named: url.imageName)
                self.memoryCache.store( $0, for: url)
                return $0
            }
            .subscribe(on: backgroundScheduler)
    
    }
    
    private func checkMemory(_ imageURL: URL) -> UIImage? {
        guard let cached = self.memoryCache.read(for: imageURL) else {
            return nil
        }
        return cached
    }
    
    private func checkDisk(_ imageURL: URL) -> UIImage? {
        if self.diskCache.exists(named: imageURL.imageName), let diskCachedData = diskCache.data(named: imageURL.imageName), let diskCachedImage = UIImage(data: diskCachedData) {
            memoryCache.store(diskCachedImage, for: imageURL)
            return diskCachedImage
        }
        return nil
    }
    
}
