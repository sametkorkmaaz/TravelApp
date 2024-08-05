//
//  BookmarksViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import CoreData
import UIKit

protocol BookmarksViewModelInterface {
    var view: BookmarksViewInterface? { get set }
    var items: [BookmarkItem] { get }
    var selectedIntex: Int? { get set }
    var onItemsUpdated: (() -> Void)? { get set } // Eklenen closure
    
    func viewDidLoad()
    func viewWillAppear()
    func fetchCoreData()
    func deleteBookmark(at indexPath: IndexPath)
}

enum BookmarkItem {
    case hotel(Hotel)
    case flight(Flight)
}

final class BookmarksViewModel {
    weak var view: BookmarksViewInterface?
    
    var items: [BookmarkItem] = []{
        didSet {
            onItemsUpdated?() // items değiştiğinde çağrılacak
        }
    }
    var selectedIntex: Int?
    var onItemsUpdated: (() -> Void)? // closure tanımlandı
    
    init(view: BookmarksViewInterface) {
        self.view = view
    }
}

extension BookmarksViewModel: BookmarksViewModelInterface {
    
    func viewDidLoad() {
        view?.prepareTableView()
    }
    
    func viewWillAppear() {
        fetchCoreData()
    }
    
    func fetchCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            view?.displayError("AppDelegate'e erişilemiyor.")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let hotelFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Hotel")
        let flightFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
        
        do {
            let hotels = try managedContext.fetch(hotelFetchRequest) as? [Hotel] ?? []
            let flights = try managedContext.fetch(flightFetchRequest) as? [Flight] ?? []
            
            items = hotels.map { BookmarkItem.hotel($0) } + flights.map { BookmarkItem.flight($0) }
            view?.reloadTableView()
        } catch let error as NSError {
            view?.displayError("Veri çekilemedi. \(error), \(error.userInfo)")
        }
    }
    
    func deleteBookmark(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            view?.displayError("AppDelegate'e erişilemiyor.")
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        switch items[indexPath.row] {
        case .hotel(let hotel):
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Hotel")
            fetchRequest.predicate = NSPredicate(format: "hotelId == %@", hotel.hotelId ?? "")
            
            do {
                let hotels = try managedContext.fetch(fetchRequest)
                for hotel in hotels {
                    managedContext.delete(hotel)
                }
                try managedContext.save()
                items.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.view?.deleteRow(at: indexPath)
                }
            } catch let error as NSError {
                view?.displayError("Silme işlemi başarısız. \(error), \(error.userInfo)")
            }
            
        case .flight(let flight):
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Flight")
            fetchRequest.predicate = NSPredicate(format: "flightDate == %@", flight.flightDate ?? "")
            
            do {
                let flights = try managedContext.fetch(fetchRequest)
                for flight in flights {
                    managedContext.delete(flight)
                }
                try managedContext.save()
                items.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.view?.deleteRow(at: indexPath)
                }
            } catch let error as NSError {
                view?.displayError("Silme işlemi başarısız. \(error), \(error.userInfo)")
            }
        }
    }
}
