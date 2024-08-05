//
//  WebService.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 18.07.2024.
//

import Alamofire

final class WebService {
    private let apiKey = "sand_81b722b6-4824-4776-a16d-2c12f6c2a486"
    private let baseURL = "https://api.liteapi.travel/v3.0/data"
    
    func fetchHotels<T: Codable>(countryCode: String, cityName: String, limit: Int, onSuccess: @escaping (T) -> (), onError: @escaping (AFError) -> ()) {
        let path = "\(baseURL)/hotels"
        let parameters: [String: String] = [
            "countryCode": countryCode,
            "cityName": cityName,
            "limit": "\(limit)"
        ]
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "X-API-Key": apiKey
        ]
        
        ServiceManager.shared.fetch(path: path, parameters: parameters, headers: headers, onSuccess: onSuccess, onError: onError)
    }
}
