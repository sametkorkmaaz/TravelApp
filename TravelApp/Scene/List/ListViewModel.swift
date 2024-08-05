//
//  ListViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import CoreData
import UIKit
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
    func searchHotelData(countryCode: String, cityName: String)
    
    func saveHotelCoreData(selectedIndexHotel: IndexPath)
    func deleteHotelCoreData(by hotelId: String)
    func isHotelBookmarked(hotelId: String?) -> Bool
    
    func saveFlightCoreData(selectedIndexFlight: IndexPath)
    func deleteFlightCoreData(by flightDate: String)
    func isFlightBookmarked(flightDate: String?) -> Bool
}

final class ListViewModel{
    weak var view: ListViewInterface?
    var kategoriTitle: String = "?"
    var hotels: [Datum] = []
    var flights: [FlightModel] = []
    var selectedIndexPath: Int?
    var cityImageUrls: [String] = []
    
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
        } else {
            // flight veri çek
            flights.append(FlightModel(departureCity: "uçak", arrivalCity: "", airport: "", price: "", date: "", arrivalCountryCode: ""))
        }
    }
    
    func searchHotelData(countryCode: String, cityName: String) {
        webService.fetchHotels(countryCode: countryCode, cityName: cityName, limit: 1, onSuccess: { [weak self] (response: HotelModel) in
            guard let self = self else { return }
            // Gelen verileri mevcut dizinin üzerine yazmak yerine ekleyin
            if let newHotels = response.data {
                self.hotels.append(contentsOf: newHotels)
            }
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
