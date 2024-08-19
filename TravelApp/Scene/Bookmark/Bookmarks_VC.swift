//
//  Bookmarks_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit
import Alamofire
import Kingfisher
import CoreData

protocol BookmarksViewInterface: AnyObject {
    func prepareTableView()
    func reloadTableView()
    func displayError(_ error: String)
    func deleteRow(at indexPath: IndexPath)
}

class Bookmarks_VC: UIViewController {
    var viewModel: BookmarksViewModelInterface!
    var manager: SearchViewModelInterface!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = BookmarksViewModel(view: self)
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookmarkToDetail",
           let destinationVC = segue.destination as? Detail_VC,
           let indexPath = viewModel.selectedIntex {
            
            switch viewModel.items[indexPath] {
            case .hotel(let hotel):
                destinationVC.detailText = hotel.hotelDescription ?? ""
                destinationVC.detailTitleText = hotel.hotelName ?? ""
                destinationVC.detailImageUrl = hotel.hotelMainPhoto ?? ""
                destinationVC.detailCategoriText = "Hotel"
                destinationVC.detailHotelStarCount = Int(hotel.hotelStars)
                destinationVC.detailBookmarkButtonText = "Remove Bookmark"
                
            case .flight(let flight):
                destinationVC.detailText = "Departure: \(flight.flightDepartureCity ?? "")\nArrival: \(flight.flightArrivalCity ?? "")\nAirport: \(flight.flightAirport ?? "")\nDate: \(flight.flightDate ?? "")\nPrice: \(flight.flightPrice ?? "")"
                destinationVC.detailTitleText = "\(flight.flightDepartureCity ?? "") → \(flight.flightArrivalCity ?? "")"
                destinationVC.detailImageUrl = "" // You might want to set a default image or URL here
                destinationVC.detailCategoriText = "Flight"
                destinationVC.detailHotelStarCount = 0
                destinationVC.detailBookmarkButtonText = "Remove Bookmark"
            }
        }
    }
}

extension Bookmarks_VC: BookmarkButtonDelegate {
    func bookmarkButtonTapped(on cell: AllTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("IndexPath bulunamadı")
            return
        }
        viewModel.deleteBookmark(at: indexPath)
    }
}

extension Bookmarks_VC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllTableViewCell", for: indexPath) as? AllTableViewCell else {
            return UITableViewCell()
        }
        
        switch viewModel.items[indexPath.row] {
        case .hotel(let hotel):
            cell.cellTitle.text = hotel.hotelName
            if let hotelMainPhoto = hotel.hotelMainPhoto, !hotelMainPhoto.isEmpty {
                if hotelMainPhoto.range(of: "bstatic") != nil {
                    cell.cellImage.image = UIImage(named: "hotel")
                } else {
                    cell.cellImage.kf.setImage(with: URL(string: hotelMainPhoto))
                }
            } else {
                cell.cellImage.image = UIImage(named: "hotel")
                }
            cell.cellDescription.text = "\(hotel.hotelCity ?? ""), \(hotel.hotelCountry ?? "")"
            cell.hotelStarCount.text = String(repeating: "⭐️", count: Int(hotel.hotelStars))
            if let countryCode = hotel.hotelCountry?.uppercased() {
                cell.cellCountryFlag.kf.setImage(with: URL(string: "https://flagsapi.com/\(countryCode)/flat/64.png"))
            }
            cell.cellCategory.text = "Hotel"
            cell.cellBookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            
        case .flight(let flight):
            cell.cellImage.image = UIImage(named: "ucak")
            cell.cellTitle.text = "\(flight.flightDepartureCity ?? "") → \(flight.flightArrivalCity ?? "")"
            cell.cellDescription.text = "\(flight.flightAirport ?? "")\nDate: \(flight.flightDate ?? "")"
            cell.hotelStarCount.text = flight.flightPrice
            cell.cellCountryFlag.kf.setImage(with: URL(string: "https://flagsapi.com/\(flight.flightArrivalCountryCode ?? "")/flat/64.png"))
            cell.cellCategory.text = "Flight"
            cell.cellBookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            
        }
        
        cell.delegate = self // Delegate ayarlaması
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIntex = indexPath.row
        performSegue(withIdentifier: "bookmarkToDetail", sender: nil)
    }
}

extension Bookmarks_VC: BookmarksViewInterface {
    
    func prepareTableView() {
        let nib = UINib(nibName: "AllTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AllTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Hata", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func deleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
