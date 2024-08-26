//
//  Home_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit
import Kingfisher
import FirebaseAnalytics

protocol HomeViewInterface: AnyObject {
    func configureHome()
    func configureHomeCollectionView()
    func reloadData()
}
class Home_VC: UIViewController {
    
    var viewModel: HomeViewModelInterface!
    
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var flights_btn: UIButton!
    @IBOutlet weak var hotels_btn: UIButton!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var home_label: UILabel!
    @IBOutlet weak var homeWelcomeText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HomeViewModel(view: self)
        viewModel.viewDidLoad()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: "id-1234567890",
          AnalyticsParameterItemName: "denemedeneme",
          AnalyticsParameterContentType: "cont",
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flightsToList" {
            Analytics.logEvent("press_flights_button", parameters: [
                "nereden": "sametsamet"
            ])
            if let destinationVC = segue.destination as? List_VC {
                destinationVC.viewModel = ListViewModel(kategoriTitle: "Flights")
            }
        }
        if segue.identifier == "hotelsToList" {
            if let destinationVC = segue.destination as? List_VC {
                destinationVC.viewModel = ListViewModel(kategoriTitle: "Hotel")
            }
        }
        if segue.identifier == "homeToDetail" {
            if let destinationVC = segue.destination as? Detail_VC, let indexPath = viewModel.selectedHomeCollectionViewHotelselectedIndexPath {
                viewModel.configureDetailVC(destinationVC, at: indexPath)
            }
        }
        
    }
    
    
}
// MARK: - Home UICollectionView
extension Home_VC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfHotels()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        if let hotelData = viewModel.getHotel(at: indexPath) {
            cell.configure(with: hotelData)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedHomeCollectionViewHotelselectedIndexPath = indexPath.row
        performSegue(withIdentifier: "homeToDetail", sender: nil)
    }
}

extension Home_VC: HomeViewInterface{
    
    func configureHome(){
        if let customFont = UIFont(name: "SourceSansPro-Black", size: 32.0) {
            homeWelcomeText.font = customFont
        } else {
            print("Font yüklenemedi.")
        }
        UIHelper.addShadow(flights_btn, renk: .pick, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        UIHelper.addShadow(hotels_btn, renk: .pick, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        
        UIHelper.roundCorners(flights_btn, radius: 10.0)
        UIHelper.roundCorners(hotels_btn, radius: 10.0)
        
        UIHelper.addBorder(flights_btn, kalinlik: 1.0, renk: .white)
        UIHelper.addBorder(hotels_btn, kalinlik: 1.0, renk: .white)
    }
    
    func configureHomeCollectionView() {
        homeCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    
    func reloadData() {
        homeCollectionView.reloadData()
    }
}
