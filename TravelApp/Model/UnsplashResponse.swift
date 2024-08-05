//
//  UnsplashResponse.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 24.07.2024.
//

import Foundation
// Unsplash API Response Structures
struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable {
    let urls: UnsplashPhotoURLs
}

struct UnsplashPhotoURLs: Codable {
    let regular: String
}
