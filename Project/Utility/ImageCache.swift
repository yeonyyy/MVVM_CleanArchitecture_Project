//
//  MemoryCache.swift
//  Project
//
//  Created by rayeon lee on 2023/09/07.
//

import Foundation
import UIKit

struct ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    func store(_ image: UIImage, for url: URL) {
        guard let key = NSURL(string: url.absoluteString) else { return }
        cache.setObject(image, forKey: key)
    }
    
    func read(for url: URL) -> UIImage? {
        guard let key = NSURL(string: url.absoluteString) else { return nil }
        return cache.object(forKey: key)
    }
}
