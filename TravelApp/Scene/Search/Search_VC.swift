import UIKit
import Kingfisher
import GoogleGenerativeAI
import Alamofire

protocol SearchViewInterface: AnyObject {
    func prepareTableView()
    func reloadTableView()
    func customViewHidden()
    func displayError(_ error: String)
    func configure()
    func setupActivityIndicator()
    func startActivityIndicator()
    func stopActivityIndicator()
}

class Search_VC: UIViewController {
    var viewModel: SearchViewModelInterface!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100 ,y: 200, width: 80, height: 80)) as UIActivityIndicatorView
    
    @IBOutlet var segmentedControl: UISegmentView!
    @IBOutlet weak var noDataCustomView: NoDataCustomView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var countriesPickerView: UIPickerView!
    @IBOutlet weak var searchPickerView: UIPickerView!
    @IBOutlet weak var flightsToTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchViewModel(view: self)
        viewModel.viewDidLoad()
        viewModel.searchData(countryCode: "AR", cityName: "")
        bindViewModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
    }
    
    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    
    @IBAction func searchTextFieldEditingChange(_ sender: Any) {
        if searchTextField.text!.count >= 3 {
            let delayTime = DispatchTime.now() + 1.0 // 1 seconds delay
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.viewModel.searchTextFieldChange(countryCode: self.viewModel.selectedCountry, cityName: self.searchTextField.text!)
            }

        }
    }
    @IBAction func SearchSegmentAction(_ sender: UISegmentedControl) {
        viewModel.setSegmentCase(sender.selectedSegmentIndex)
        updateUIForSegment()
    }
    //-------------------------------------
    @IBAction func segmentedControlDidChange(_ sender: Any) {
        segmentedControl.underlinePosition()
    }
    
    func updateUIForSegment() {
        switch viewModel.segmentCase {
        case 0:
            searchTextField.text = ""
            flightsToTextField.isHidden = true
            searchPickerView.isHidden = false
            searchTextField.isHidden = false
        case 1:
            flightsToTextField.text = ""
            searchPickerView.isHidden = true
            searchTextField.isHidden = true
            flightsToTextField.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func searchButton(_ sender: Any) {
        viewModel.searchButtonTapped(
            searchText: searchTextField.text!,
            flightFromText: "İstanbul",
            flightToText: flightsToTextField.text!
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToDetail",
           let destinationVC = segue.destination as? Detail_VC,
           let indexPath = viewModel.selectedIndexPath {
            // Pass the selected data to the destination view controller
            if viewModel.segmentCase == 0 {
                let selectedHotel = viewModel.hotels[indexPath]
                AnalyticsManager.shared.log(.lookDetailHotel(.init(hotel_name: selectedHotel.name!, hotel_id: selectedHotel.id!, hotel_country_code: selectedHotel.country!, hotel_city: selectedHotel.city!, origin: "SearchView")))
                destinationVC.detailText = selectedHotel.hotelDescription!
                destinationVC.detailTitleText = selectedHotel.name!
                destinationVC.detailImageUrl = selectedHotel.mainPhoto!
                destinationVC.detailHotelId = selectedHotel.id!
                destinationVC.detailCategoriText = "Hotel"
                destinationVC.detailHotelStarCount = Int(selectedHotel.stars!)
                destinationVC.detailHotelCountry = selectedHotel.country!
                destinationVC.detailHotelCity = selectedHotel.city!
                destinationVC.detailHotelAddress = selectedHotel.address!
                
               // destinationVC.detailBookmarkButtonText = "Deneme Bookmark"
                let hotel = viewModel.hotels[indexPath]
                let isBookmarked = viewModel.isHotelBookmarked(hotelId: hotel.id)
                if isBookmarked {
                    destinationVC.detailBookmarkButtonText = "Remove Bookmark"
                } else {
                    destinationVC.detailBookmarkButtonText = "Add Bookmark"
                }
                

            }
            if viewModel.segmentCase == 1 {
                let selectedFlight = viewModel.flights[indexPath]
                AnalyticsManager.shared.log(.lookDetailFlight(.init(flight_airport_name: selectedFlight.airport!, flight_arrival_city: selectedFlight.arrivalCity!, flight_arrival_city_country_code: selectedFlight.arrivalCountryCode!, origin: "SearchView")))
                destinationVC.detailImageUrl = viewModel.cityImageUrls[indexPath]
                destinationVC.detailTitleText = "İstanbul → " + " \(flightsToTextField.text!)"
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
    
    func showErrorAlert(message: String) {
        /*let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)*/
        print("ekrana hata ver")
    }
}

extension Search_VC: BookmarkButtonDelegate {
    func bookmarkButtonTapped(on cell: AllTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            if viewModel.segmentCase == 0 {
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

// MARK: - UIPickerView
extension Search_VC: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.countriesList.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: viewModel.countriesList[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.pick])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedCountry = viewModel.countriesList[row]
        viewModel.searchData(countryCode: viewModel.selectedCountry, cityName: searchTextField.text ?? "")
    }
}

// MARK: - UITableView
extension Search_VC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.segmentCase == 0 {
            if viewModel.hotels.count == 0 {
                noDataCustomView.isHidden = false
                return viewModel.hotels.count
            } else{
                noDataCustomView.isHidden = true
                return viewModel.hotels.count
            }
        }else {
            if viewModel.flights.count == 0 {
                noDataCustomView.isHidden = false
                return viewModel.flights.count
            } else{
                noDataCustomView.isHidden = true
                return viewModel.flights.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllTableViewCell", for: indexPath) as? AllTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self // Delegate ayarlaması

        if viewModel.segmentCase == 0 {
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
        }

        if viewModel.segmentCase == 1 {
            let flight = viewModel.flights[indexPath.row]
            cell.cellTitle.text = "\(flight.departureCity!) → \(flight.arrivalCity!)"
            cell.cellDescription.text = "\(flight.airport!)\n " + "\(flight.date!)"
            cell.hotelStarCount.text = flight.price
            if viewModel.flights.count <= viewModel.cityImageUrls.count {
                cell.cellImage.kf.setImage(with: URL(string: viewModel.cityImageUrls[indexPath.row]))
            } else {
                cell.cellImage.kf.setImage(with: URL(string: viewModel.cityImageUrls.randomElement()!))
            }

            cell.cellCountryFlag.kf.setImage(with: URL(string: "https://flagsapi.com/\(flight.arrivalCountryCode!)/flat/64.png")!)
            cell.cellCategory.text = "Flight"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedIndexPath = indexPath.row
        performSegue(withIdentifier: "searchToDetail", sender: nil)
    }
}

extension Search_VC: SearchViewInterface {
    
    func configure() {
        self.segmentedControl.frame = CGRect(x: self.segmentedControl.frame.minX, y: self.segmentedControl.frame.minY, width: segmentedControl.frame.width, height: 60)
        segmentedControl.highlightSelectedSegment()
        noDataCustomView.isHidden = true
        UIHelper.addBorder(searchTextField, kalinlik: 0.5, renk: .gray)
        UIHelper.roundCorners(searchTextField, radius: 5)
        UIHelper.addBorder(flightsToTextField, kalinlik: 0.5, renk: .gray)
        UIHelper.roundCorners(flightsToTextField, radius: 5)
        
        flightsToTextField.isHidden = true
    }
    
    func prepareTableView() {
        let nib = UINib(nibName: "AllTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AllTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func customViewHidden() {
        noDataCustomView.isHidden = true
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .pick
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.backgroundColor = (UIColor (white: 0.8, alpha: 0.8))
        activityIndicator.layer.cornerRadius = 10
        self.view.addSubview(activityIndicator)
        }
    func startActivityIndicator() {
        print("start")
        activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Hata", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
