//
//  HotelModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 18.07.2024.
//

import Foundation

// MARK: - HotelModel
struct HotelModel: Codable {
    let data: [Datum]?
    let hotelIDS: String?

    enum CodingKeys: String, CodingKey {
        case data
        case hotelIDS = "hotelIds"
    }
}

// MARK: - Datum
struct Datum: Codable {
    let id, name, hotelDescription: String?
    let country, city: String?
    let address: String?
    let mainPhoto: String?
    let stars: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, hotelDescription, country, city, address
        case mainPhoto = "main_photo"
        case stars
    }
}
