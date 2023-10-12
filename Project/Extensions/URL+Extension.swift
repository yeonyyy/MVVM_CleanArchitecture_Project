//
//  URL+Extension.swift
//  Project
//
//  Created by rayeon lee on 2023/09/07.
//

import Foundation

extension URL {
    var imageName: String { "\(lastPathComponent).png" }
}
