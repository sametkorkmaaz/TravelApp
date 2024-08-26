//
//  AnalyticsManager.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 26.08.2024.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    private init() {}
    static let shared = AnalyticsManager()
    
    public func log(_ event: AnalyticsEvent) {
        guard let parameters = event.parameters else {
            return
        }
        Analytics.logEvent(event.eventName, parameters: parameters)
    }
}

protocol AnalyticsEventProtocol: Encodable {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

enum AnalyticsEvent: AnalyticsEventProtocol {
    case searchFlight(SearchFlightEvent)
    case searchHotel(SearchHotelEvent)
    case lookDetailHotel(LookDetailHotelEvent)
    case lookDetailFlight(LookDetailFlightEvent)
    case addBookmarkHotel(AddBookmarkHotelEvent)
    case addBookmarkFlight(AddBookmarkFlightEvent)
    
    var eventName: String {
        switch self {
        case .searchFlight: return "search_location_for_flight"
        case .searchHotel: return "search_hotel"
        case .lookDetailHotel: return "look_detail_hotel"
        case .lookDetailFlight: return "look_detail_flight"
        case .addBookmarkHotel: return "add_bookmark_hotel"
        case .addBookmarkFlight: return "add_bookmark_flight"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchFlight(let event):
            return event.encodeToDictionary()
        case .searchHotel(let event):
            return event.encodeToDictionary()
        case .lookDetailHotel(let event):
            return event.encodeToDictionary()
        case .lookDetailFlight(let event):
            return event.encodeToDictionary()
        case .addBookmarkHotel(let event):
            return event.encodeToDictionary()
        case .addBookmarkFlight(let event):
            return event.encodeToDictionary()
        }
    }
}

extension Encodable {
    func encodeToDictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return dict
        } catch {
            print("Error encoding \(self): \(error)")
            return nil
        }
    }
}

struct SearchFlightEvent: Codable{
    let searchLocationName: String
    let timestamp: Date
    let origin: String
}

struct SearchHotelEvent: Codable{
    let hotel_city: String
    let hotel_country_code: String
    let timestamp: Date
    let origin: String
}

struct LookDetailHotelEvent: Codable{
    let hotel_name: String
    let hotel_id: String
    let hotel_country_code: String
    let hotel_city: String
    let origin: String
}

struct LookDetailFlightEvent: Codable{
    let flight_airport_name: String
    let flight_arrival_city: String
    let flight_arrival_city_country_code: String
    let origin: String
}

struct AddBookmarkHotelEvent: Codable{
    let hotel_name: String
    let hotel_id: String
    let hotel_country_code: String
    let hotel_city: String
    let origin: String
}

struct AddBookmarkFlightEvent: Codable{
    let flight_airport_name: String
    let flight_arrival_city: String
    let flight_arrival_city_country_code: String
    let origin: String
}
