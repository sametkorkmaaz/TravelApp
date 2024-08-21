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
    func configureDetailVC(_ detailVC: Detail_VC, at indexPath: Int)
    func getHotel(at indexPath: IndexPath) -> Datum?
    func numberOfHotels() -> Int
}

final class HomeViewModel {
    weak var view: HomeViewInterface?
    var selectedHomeCollectionViewHotelselectedIndexPath: Int?
    private var hotels: [HotelModel] = []
    
    init(view: HomeViewInterface) {
        self.view = view
        self.hotels = HomeCollectionViewData.collectionHotels
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
    
    func configureDetailVC(_ detailVC: Detail_VC, at indexPath: Int) {
        let selectedHotel = hotels[indexPath]
        detailVC.detailTitleText = selectedHotel.data?.first?.name ?? "No Title"
        detailVC.detailText = selectedHotel.data?.first?.hotelDescription ?? "No Description"
        detailVC.detailImageUrl = selectedHotel.data?.first?.mainPhoto ?? ""
        detailVC.detailHotelId = selectedHotel.data?.first?.id ?? ""
        detailVC.detailCategoriText = "Hotel"
        detailVC.detailHotelCity = selectedHotel.data?.first?.city ?? "No City"
        detailVC.detailHotelStarCount = Int(selectedHotel.data?.first?.stars ?? 0)
        detailVC.detailHotelAddress = selectedHotel.data?.first?.address ?? "No Address"
        detailVC.detailHotelCountry = selectedHotel.data?.first?.country ?? "No Country"
        let isBookmarked = isHotelBookmarked(hotelId: selectedHotel.data?.first?.id)
        detailVC.detailBookmarkButtonText = isBookmarked ? "Remove Bookmark" : "Add Bookmark"
    }
    
    func getHotel(at indexPath: IndexPath) -> Datum? {
        return hotels[indexPath.row].data?.first
    }
    
    func numberOfHotels() -> Int {
        return hotels.count
    }
}
