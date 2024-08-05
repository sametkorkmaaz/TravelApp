//
//  ServiceManager.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 18.07.2024.
//

import Alamofire

final class ServiceManager {
    static let shared: ServiceManager = ServiceManager()
    
    private init() {}
    
    func fetch<T: Codable>(path: String, parameters: [String: String]?, headers: HTTPHeaders?, onSuccess: @escaping (T) -> (), onError: @escaping (AFError) -> ()) {
        AF.request(path, parameters: parameters, headers: headers).validate().responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let model):
                onSuccess(model)
            case .failure(let error):
                onError(error)
            }
        }
    }
}
