//
//  Home_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit
import Kingfisher

protocol HomeViewInterface: AnyObject {
    func configureHome()
    func configureHomeCollectionView()
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flightsToList" {
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
                let selectedHotel = HomeCollectionViewData.collectionHotels[indexPath]
                destinationVC.detailTitleText = (selectedHotel.data?.first?.name)!
                destinationVC.detailText = (selectedHotel.data?.first?.hotelDescription)!
                destinationVC.detailImageUrl = (selectedHotel.data?.first?.mainPhoto)!
                destinationVC.detailHotelId = (selectedHotel.data?.first?.id)!
                destinationVC.detailCategoriText = "Hotel"
                destinationVC.detailHotelCity = (selectedHotel.data?.first?.city)!
                destinationVC.detailHotelStarCount = Int((selectedHotel.data?.first?.stars)!)
                destinationVC.detailHotelAddress = (selectedHotel.data?.first?.address)!
                destinationVC.detailHotelCountry = (selectedHotel.data?.first?.country)!
                let isBookmarked = viewModel.isHotelBookmarked(hotelId: (selectedHotel.data?.first?.id)!)
                if isBookmarked {
                    destinationVC.detailBookmarkButtonText = "Remove Bookmark"
                } else {
                    destinationVC.detailBookmarkButtonText = "Add Bookmark"
                }
            }
        }
        
    }
    
    
}
// MARK: - Home UICollectionView
extension Home_VC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HomeCollectionViewData.collectionHotels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        let collectionData = HomeCollectionViewData.collectionHotels
        cell.collectionViewDescriptionText.text = "hbsfkjdasbdkjsabdkasbdjhasbdjhasbdjhasbdjhasbdjabsjdas"
        
        if let hotelName = collectionData[indexPath.row].data?.first?.name {
            cell.collectionViewCategoriText.text = hotelName
        } else {
            cell.collectionViewCategoriText.text = "No Name"
        }
        if let hotelImage = collectionData[indexPath.row].data?.first?.mainPhoto {
            cell.collectionViewImage.kf.setImage(with: URL(string: hotelImage))
        } else {
            cell.collectionViewImage.image = UIImage(named: "hotel")
        }
        cell.collectionViewDescriptionText.text = collectionData[indexPath.row].data?.first?.hotelDescription
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
        UIHelper.addShadow(flights_btn, renk: .red, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        UIHelper.addShadow(hotels_btn, renk: .red, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        
        UIHelper.roundCorners(flights_btn, radius: 10.0)
        UIHelper.roundCorners(hotels_btn, radius: 10.0)
        
        UIHelper.addBorder(flights_btn, kalinlik: 1.0, renk: .white)
        UIHelper.addBorder(hotels_btn, kalinlik: 1.0, renk: .white)
    }
    
    func configureHomeCollectionView() {
        homeCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
}
