//
//  DetailViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import CoreData
import UIKit

protocol DetailViewModelInterface{
    var view: DetailViewInterface? { get set }
    
    func viewDidLoad()
    func detailBookmarkButton()
    
    func detailViewAddBookmarkButtonSaveCoreDate(detailHotel: [HotelModel])
    func detailViewRemoveBookmarkButtonDeleteCoreDate(hotelId: String)
}

final class DetailViewModel{
    var view: DetailViewInterface?
    var hotelId: String?
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(view: DetailViewInterface) {
        self.view = view
    }
}

extension DetailViewModel: DetailViewModelInterface{

    func viewDidLoad() {
        view?.configureDetailPage()
        view?.createHotelArray()
    }
    
    func detailBookmarkButton() {
        view?.configureDetailBookmarkButtonText()
    }

    func detailViewAddBookmarkButtonSaveCoreDate(detailHotel: [HotelModel]) {
        let selectedHotel = detailHotel[0].data![0]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a new Hotel entity
        let entity = NSEntityDescription.entity(forEntityName: "Hotel", in: managedContext)!
        let hotel = NSManagedObject(entity: entity, insertInto: managedContext)
        AnalyticsManager.shared.log(.addBookmarkHotel(.init(hotel_name: selectedHotel.name!, hotel_id: selectedHotel.id!, hotel_country_code: selectedHotel.country!, hotel_city: selectedHotel.city!, origin: "DetailView")))
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
    
    func detailViewRemoveBookmarkButtonDeleteCoreDate(hotelId: String) {
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
    
}
