//
//  List_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 11.07.2024.
//

import UIKit
import Kingfisher

protocol ListViewInterface: AnyObject{
    func configurePage()
    func reloadTableView()
    func prepareTableView()
}

final class List_VC: UIViewController {
    var viewModel: ListViewModel!
    
    @IBOutlet weak var kategoriTitle_lbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listToDetail",
           let destinationVC = segue.destination as? Detail_VC,
           let indexPath = viewModel.selectedIndexPath {
            // Pass the selected data to the destination view controller
            if viewModel.kategoriTitle == "Hotel" {
                let selectedHotel = viewModel.hotels[indexPath]
                destinationVC.detailText = selectedHotel.hotelDescription!
                destinationVC.detailTitleText = selectedHotel.name!
                destinationVC.detailImageUrl = selectedHotel.mainPhoto!
                destinationVC.detailCategoriText = "Hotel"
                destinationVC.detailHotelStarCount = Int(selectedHotel.stars!)
                
               // destinationVC.detailBookmarkButtonText = "Deneme Bookmark"
                let hotel = viewModel.hotels[indexPath]
                let isBookmarked = viewModel.isHotelBookmarked(hotelId: hotel.id)
                if isBookmarked {
                    destinationVC.detailBookmarkButtonText = "Remove Bookmark"
                } else {
                    destinationVC.detailBookmarkButtonText = "Add Bookmark"
                }
                

            }
            if viewModel.kategoriTitle == "Flight" {
                let selectedFlight = viewModel.flights[indexPath]
                destinationVC.detailImageUrl = viewModel.cityImageUrls[indexPath]
                destinationVC.detailTitleText = "Istanbul → " + " \(selectedFlight.arrivalCity!)"
                destinationVC.detailCategoriText = "Flight"
                destinationVC.detailText = "\(selectedFlight.airport!)\n\(selectedFlight.date!)\n\(selectedFlight.price!)"
                
                let flight = viewModel.flights[indexPath]
                let isBookmarked = viewModel.isFlightBookmarked(flightDate: flight.date)
                if isBookmarked {
                    destinationVC.detailBookmarkButtonText = "Remove Bookmark"
                } else {
                    destinationVC.detailBookmarkButtonText = "Add Bookmark"
                }
            }
            

        }
    }
    @IBAction func listViewBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension List_VC: ListViewInterface{
    
    func configurePage() {
        kategoriTitle_lbl.text = viewModel.kategoriTitle
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func prepareTableView() {
        let nib = UINib(nibName: "AllTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AllTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}
extension List_VC: BookmarkButtonDelegate{
    func bookmarkButtonTapped(on cell: AllTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            if viewModel.kategoriTitle == "Hotel" {
                if cell.isBookmarkFilled {
                    if let hotelId = viewModel.hotels[indexPath.row].id {
                        viewModel.deleteHotelCoreData(by: hotelId)
                    }
                } else {
                    viewModel.saveHotelCoreData(selectedIndexHotel: indexPath)
                }
            } else {
                if cell.isBookmarkFilled {
                    if let flightDate = viewModel.flights[indexPath.row].date {
                        print("ıçak silindi")
                        viewModel.deleteFlightCoreData(by: flightDate)
                    }
                } else {
                    print("uçak kayıt")
                    viewModel.saveFlightCoreData(selectedIndexFlight: indexPath)
                }
            }
        }
    }
    
}
extension List_VC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.kategoriTitle == "Hotel"{
            return viewModel.hotels.count
        }else{
            return viewModel.flights.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllTableViewCell", for: indexPath) as? AllTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        if viewModel.kategoriTitle == "Hotel"{
            let hotel = viewModel.hotels[indexPath.row]
            cell.cellTitle.text = hotel.name
            if hotel.mainPhoto?.range(of: "bstatic") != nil || hotel.mainPhoto == "" {
                cell.cellImage.image = UIImage(named: "hotel")
            } else {
                cell.cellImage.kf.setImage(with: URL(string: hotel.mainPhoto!))
            }
            cell.cellDescription.text = "\(hotel.city!), \(hotel.country!)"
            if let stars = hotel.stars {
                cell.hotelStarCount.text = String(repeating: "⭐️", count: Int(stars))
            } else {
                cell.hotelStarCount.text = "No rating"
            }
            cell.cellCountryFlag.kf.setImage(with: URL(string: "https://flagsapi.com/\(hotel.country!.uppercased())/flat/64.png")!)
            cell.cellCategory.text = "Hotel"
            
            // Bookmark durumunu kontrol et ve ayarla
            let isBookmarked = viewModel.isHotelBookmarked(hotelId: hotel.id)
            cell.isBookmarkFilled = isBookmarked
            let bookmarkImage = isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
            cell.cellBookmarkButton.setImage(bookmarkImage, for: .normal)
        } else{
            // LİST FLİGHT TABLEVİEW
            cell.textLabel?.text = viewModel.flights[0].departureCity
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndexPath = indexPath.row
        performSegue(withIdentifier: "listToDetail", sender: nil)
    }
    
    
}
