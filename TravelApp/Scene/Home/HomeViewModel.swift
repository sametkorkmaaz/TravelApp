//
//  HomeViewModel.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import Foundation
import CoreData
import UIKit

protocol HomeViewModelInterface {
    var view: HomeViewInterface? { get set }
    var selectedHomeCollectionViewHotelselectedIndexPath: Int? { get set }
    
    func viewDidLoad()
    func prepareHomeCollectionView()
    func isHotelBookmarked(hotelId: String?) -> Bool
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    var selectedHomeCollectionViewHotelselectedIndexPath: Int?
    
    init(view: HomeViewInterface) {
        self.view = view
    }
}

extension HomeViewModel: HomeViewModelInterface{
    
    func viewDidLoad() {
        view?.configureHome()
        prepareHomeCollectionView()
    }
    
    func prepareHomeCollectionView() {
        view?.configureHomeCollectionView()
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
}
