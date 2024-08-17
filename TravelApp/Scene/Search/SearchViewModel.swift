//
//  SearchViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import Alamofire
import GoogleGenerativeAI
import CoreData
import UIKit

protocol SearchViewModelInterface {
    var view: SearchViewInterface? { get set }
    var hotels: [Datum] { get }
    var flights: [FlightModel] { get }
    var selectedIndexPath: Int? { get set }
    var cityImageUrls: [String] { get }
    var countriesList: [String] { get }
    var segmentCase: Int { get set }
    var selectedCountry: String { get set }
    var onDataUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func viewDidLoad()
    func viewDidAppear()
    func clearData()
    func setSegmentCase(_ segment: Int)
    func searchButtonTapped(searchText: String?, flightFromText: String?, flightToText: String?)
    
    func searchData(countryCode: String, cityName: String)
    func sendMessageGemini()
    func sendMessageCityImage(cityName: String)
    func updatePrompt(from: String?, to: String?)
    
    func saveHotelCoreData(selectedIndexHotel: IndexPath)
    func deleteHotelCoreData(by hotelId: String)
    func isHotelBookmarked(hotelId: String?) -> Bool
    
    func saveFlightCoreData(selectedIndexFlight: IndexPath)
    func deleteFlightCoreData(by flightDate: String)
    func isFlightBookmarked(flightDate: String?) -> Bool
    
    func searchTextFieldChange(countryCode: String, cityName: String)
}

final class SearchViewModel {
    weak var view: SearchViewInterface?
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    
    var flightFromCity: String?
    var flightToCity: String?
    var selectedCountry = "AR"
    var hotels: [Datum] = []
    var flights: [FlightModel] = []
    var cityImageUrls: [String] = []
    var segmentCase = 0
    var prompt = ""
    var selectedIndexPath: Int?
    
    let countriesList = ["AR", "AU", "BR", "CA", "CN", "DE", "EG", "ES", "FR", "GB", "IN", "IT", "JP", "KR", "MX", "NG", "RU", "TR", "US", "ZA"]
    
    let webService = WebService()
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(view: SearchViewInterface) {
        self.view = view
    }
}

extension SearchViewModel: SearchViewModelInterface {
    
    func viewDidLoad() {
        view?.prepareTableView()
        view?.configure()
        view?.setupActivityIndicator()
    }
    func viewDidAppear() {
        view?.customViewHidden()
        view?.reloadTableView()
    }
    
    func setSegmentCase(_ segment: Int) {
        segmentCase = segment
        clearData()
    }
    
    func clearData() {
        if segmentCase == 0 {
            flights.removeAll()
        } else {
            hotels.removeAll()
        }
        onDataUpdated?()
    }
    
    func searchButtonTapped(searchText: String?, flightFromText: String?, flightToText: String?) {
        if segmentCase == 0 {
            searchData(countryCode: selectedCountry, cityName: searchText ?? "")
        } else if segmentCase == 1 {
            view?.customViewHidden()
            view?.startActivityIndicator()
            sendMessageCityImage(cityName: flightToText ?? "")
            updatePrompt(from: flightFromText, to: flightToText)
            sendMessageGemini()
        }
    }
    func searchTextFieldChange(countryCode: String, cityName: String) {
        searchData(countryCode: countryCode, cityName: cityName)
    }
    
    func sendMessageGemini() {
        Task {
            do {
                let response = try await model.generateContent(prompt)
                guard let text = response.text else {
                    self.onError?("No response text")
                    return
                }
                if let data = text.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        let flightArray = try decoder.decode([FlightModel].self, from: data)
                        self.flights = flightArray
                        view?.stopActivityIndicator()
                        self.onDataUpdated?()
                    } catch {
                        self.onError?("JSON decode error: \(error)")
                    }
                } else {
                    self.onError?("Data conversion error")
                }
            } catch {
                self.onError?("Error: \(error)")
            }
        }
    }
    
    func searchData(countryCode: String, cityName: String) {
        webService.fetchHotels(countryCode: countryCode, cityName: cityName, limit: 15, onSuccess: { [weak self] (response: HotelModel) in
            guard let self = self else { return }
            self.hotels = response.data ?? []
            self.onDataUpdated?()
        }, onError: { [weak self] error in
            self?.onError?(error.localizedDescription)
        })
    }
    
    func sendMessageCityImage(cityName: String) {
        let apiKey = "zbUOr9jsbwxAE-DrrsaBiL-wMzijqZSQxueoyLDAEe0"
        let urlString = "https://api.unsplash.com/search/photos?page=1&query=\(cityName)&client_id=\(apiKey)"
        
        AF.request(urlString, method: .get)
            .validate()
            .responseDecodable(of: UnsplashResponse.self) { [weak self] response in
                switch response.result {
                case .success(let unsplashResponse):
                    self?.cityImageUrls = unsplashResponse.results.map { $0.urls.regular }
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onError?("Request failed with error: \(error)")
                }
            }
    }
    
    func updatePrompt(from: String?, to: String?) {
        prompt = """
        Bana sana vereceğim 2 şehir arasında 20.08.2024 ve sonrasında giden güncel 10 adet uçak bileti bilgisini JSON verisi olarak ver. \
        Sana gönderdiğim şehir isimleri geçersizse dönüş olarak sadece error yaz. Sana sorduğum şehir isimleri dünyada yoksa dönüş olarak JSON verme sadece metin olarak 'Error' yaz. \
        Şehirler= Kalkış şehri:\(from ?? ""), İniş şehri:\(to ?? ""). \
        JSON formatında: Kalkış şehri, İniş şehri, İniş şehrinin ülke kodu, Kalkış şehrindeki havaalanı bilgisi, Fiyat bilgisi, Tarih ve saat olsun. \
        BU verileri ingilizce tanımlamaları ile ver. Dönüş olarak sadece JSON formatında dönüş yaz. Başka hiçbir şey yazma. \
        Dönüş [ ile başlasın ve ] ile bitsin. Verileri vereceğim bu swift veri modeline uygun ver= struct FlightModel: Codable { let departureCity: String? let arrivalCity: String? let airport: String? let price: String? let date: String? let arrivalCountryCode: String?
        """
    }
    
    func saveHotelCoreData(selectedIndexHotel: IndexPath) {
        let selectedHotel = hotels[selectedIndexHotel.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a new Hotel entity
        let entity = NSEntityDescription.entity(forEntityName: "Hotel", in: managedContext)!
        let hotel = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the values for the entity
        hotel.setValue(selectedHotel.id, forKeyPath: "hotelId")
        hotel.setValue(selectedHotel.name, forKeyPath: "hotelName")
        hotel.setValue(selectedHotel.hotelDescription, forKeyPath: "hotelDescription")
        hotel.setValue(selectedHotel.country, forKeyPath: "hotelCountry")
        hotel.setValue(selectedHotel.city, forKeyPath: "hotelCity")
        hotel.setValue(selectedHotel.address, forKeyPath: "hotelAddress")
        hotel.setValue(selectedHotel.mainPhoto, forKeyPath: "hotelMainPhoto")
        if let stars = selectedHotel.stars {
            hotel.setValue(stars, forKeyPath: "hotelStars")
        }
        
        // Save the context
        do {
            try managedContext.save()
            print("Saved successfully!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteHotelCoreData(by hotelId: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            onError?("AppDelegate'e erişilemiyor.")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Hotel")
        fetchRequest.predicate = NSPredicate(format: "hotelId == %@", hotelId)
        
        do {
            let hotels = try managedContext.fetch(fetchRequest)
            for hotel in hotels {
                managedContext.delete(hotel)
            }
            try managedContext.save()
            
            // CoreData'dan sildikten sonra local listeden de silin
            onDataUpdated?()
            
        } catch let error as NSError {
            onError?("Silme işlemi başarısız. \(error), \(error.userInfo)")
        }
    }
    
    func isHotelBookmarked(hotelId: String?) -> Bool {
        guard let hotelId = hotelId else { return false }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Hotel")
        fetchRequest.predicate = NSPredicate(format: "hotelId == %@", hotelId)
        
        do {
            let hotels = try managedContext.fetch(fetchRequest)
            return hotels.count > 0
        } catch {
            return false
        }
    }
    
    func saveFlightCoreData(selectedIndexFlight: IndexPath) {
        let selectedFlight = flights[selectedIndexFlight.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a new Flight entity
        let entity = NSEntityDescription.entity(forEntityName: "Flight", in: managedContext)!
        let flight = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the values for the entity
        flight.setValue(selectedFlight.price, forKeyPath: "flightPrice")
        flight.setValue(selectedFlight.departureCity, forKeyPath: "flightDepartureCity")
        flight.setValue(selectedFlight.date, forKeyPath: "flightDate")
        flight.setValue(selectedFlight.arrivalCountryCode, forKeyPath: "flightArrivalCountryCode")
        flight.setValue(selectedFlight.arrivalCity, forKeyPath: "flightArrivalCity")
        flight.setValue(selectedFlight.airport, forKeyPath: "flightAirport")
        
        // Save the context
        do {
            try managedContext.save()
            print("Saved successfully!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFlightCoreData(by flightDate: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            onError?("AppDelegate'e erişilemiyor.")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        fetchRequest.predicate = NSPredicate(format: "flightDate == %@", flightDate)
        
        do {
            let flights = try managedContext.fetch(fetchRequest)
            for flight in flights {
                managedContext.delete(flight)
            }
            try managedContext.save()
            
            // CoreData'dan sildikten sonra local listeden de silin
            onDataUpdated?()
            
        } catch let error as NSError {
            onError?("Silme işlemi başarısız. \(error), \(error.userInfo)")
        }
    }
    
    func isFlightBookmarked(flightDate: String?) -> Bool {
        guard let flightDate = flightDate else { return false }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        fetchRequest.predicate = NSPredicate(format: "flightDate == %@", flightDate)
        
        do {
            let flights = try managedContext.fetch(fetchRequest)
            return flights.count > 0
        } catch {
            return false
        }
    }

}
