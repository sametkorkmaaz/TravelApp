//
//  ListViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import CoreData
import UIKit
import GoogleGenerativeAI
import Alamofire

protocol ListViewModelInterface{
    var view: ListViewInterface? { get set }
    var kategoriTitle: String { get set }
    var hotels: [Datum] { get }
    var flights: [FlightModel] { get }
    var selectedIndexPath: Int? { get set }
    var cityImageUrls: [String] { get }
    var onDataUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func viewDidLoad()
    func fetchData(kategori: String)
    // Hotel fetch metods
    func searchHotelData(countryCode: String, cityName: String)
    // Flight fetch metods
    func sendMessageGemini()
    func sendMessageCityImage(cityName: String)
    func updatePrompt(from: String?)
    // Hotel CoreData and bookmark button
    func saveHotelCoreData(selectedIndexHotel: IndexPath)
    func deleteHotelCoreData(by hotelId: String)
    func isHotelBookmarked(hotelId: String?) -> Bool
    // Flight CoreData and bookmark button
    func saveFlightCoreData(selectedIndexFlight: IndexPath)
    func deleteFlightCoreData(by flightDate: String)
    func isFlightBookmarked(flightDate: String?) -> Bool
}

final class ListViewModel{
    weak var view: ListViewInterface?
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    var kategoriTitle: String = "?"
    var hotels: [Datum] = []
    var flights: [FlightModel] = []
    var selectedIndexPath: Int?
    var cityImageUrls: [String] = []
    var prompt = ""
    
    let countriesList = ["AR", "AU", "BR", "CA", "CN", "DE", "EG", "ES", "FR", "GB", "IN", "IT", "JP", "KR", "MX", "NG", "RU", "TR", "US", "ZA"]

    let webService = WebService()
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(kategoriTitle: String) {
        self.kategoriTitle = kategoriTitle
    }
}

extension ListViewModel: ListViewModelInterface{

    func viewDidLoad() {
        view?.configurePage()
        view?.prepareTableView()
        view?.setupActivityIndicator()
        view?.startActivityIndicator()
        fetchData(kategori: kategoriTitle)
    }
    
    func fetchData(kategori: String) {
        print(kategori)
        if kategori == "Hotel"{
            let delay = 0.2 // 1 saniye bekleme süresi

            for (index, code) in countriesList.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                    self.searchHotelData(countryCode: code, cityName: "")
                }
            }
        } 
        if kategori == "Flights" {
            view?.startActivityIndicator()
            updatePrompt(from: "İstanbul")
            sendMessageGemini()
            sendMessageCityImage(cityName: "İstanbul")
        }
    }
    
    func searchHotelData(countryCode: String, cityName: String) {
        webService.fetchHotels(countryCode: countryCode, cityName: cityName, limit: 1, onSuccess: { [weak self] (response: HotelModel) in
            guard let self = self else { return }
            // Gelen verileri mevcut dizinin üzerine yazmak yerine ekleyin
            if let newHotels = response.data {
                self.hotels.append(contentsOf: newHotels)
            }
            view?.stopActivityIndicator()
            self.onDataUpdated?()
            self.view?.reloadTableView()
        }, onError: { [weak self] error in
            print("error list")
            print(error.localizedDescription)
            self?.onError?(error.localizedDescription)
        })

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
    
    func sendMessageGemini() {
        print("çlaıştı gemini")
        view?.startActivityIndicator()
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
                        print("stop")
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
    
    func sendMessageCityImage(cityName: String) {
        print("çlaıştı city")
        view?.startActivityIndicator()
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
    func updatePrompt(from: String?) {
        print("çlaıştı promt")
        view?.startActivityIndicator()
        prompt = """
         Sana vereceğim kalkış şehir ile rastgele şehirler arasında 20.09.2024 ve sonrasında giden güncel 10 adet uçak bileti bilgisini JSON verisi olarak ver. Gidilen şehirler rastgele ülkelerden de olabilir. Aynı ülke içinde farklı şehirler de olabilir. \
        Kalkış şehri:\(from ?? "")\
        JSON formatında: Kalkış şehri, İniş şehri, İniş şehrinin ülke kodu, Kalkış şehrindeki havaalanı bilgisi, Fiyat bilgisi, Tarih ve saat olsun. \
        BU verileri ingilizce tanımlamaları ile ver. Dönüş olarak sadece JSON formatında dönüş yaz. Başka hiçbir şey yazma. \
        Dönüş [ ile başlasın ve ] ile bitsin. Verileri vereceğim bu swift veri modeline uygun ver-> struct FlightModel: Codable { let departureCity: String? let arrivalCity: String? let airport: String? let price: String? let date: String? let arrivalCountryCode: String?
        """
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
