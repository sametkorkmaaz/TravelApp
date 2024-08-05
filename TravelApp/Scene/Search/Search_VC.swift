//
//  Search_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class Search_VC: UIViewController {
    
    let webService = WebService()
    
    let countriesList = ["AR", "AU", "BR", "CA", "CN", "DE", "EG", "ES", "FR", "GB", "IN", "IT", "JP", "KR", "MX", "NG", "RU", "TR", "US", "ZA"]
    
    let denemeList = ["TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR","TR"]
    var selectedCountry = "XX"

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var countriesPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIHelper.addBorder(searchTextField, kalinlik: 0.5, renk: .gray)
        UIHelper.roundCorners(searchTextField, radius: 5)
        
    }
    
    @IBAction func searchButton(_ sender: Any) {
        searchData(countryCode: selectedCountry)
    }

    
    @IBAction func detailButton(_ sender: Any) {
        performSegue(withIdentifier: "segue", sender: nil)
    }
    func searchData(countryCode: String){
        webService.fetchHotels(countryCode: countryCode, cityName: String(searchTextField.text!), limit: 10, onSuccess: { (response: HotelModel) in
            print("searchData FONK çalıştı")
            print("countrycode: \(countryCode) cityname: \(String(self.searchTextField.text!))")
            print(response.data!.count)

            
        }, onError: { error in
            print("searchDATA HATA! FONK çalıştı")
            print("Error: \(error.localizedDescription)")
        })
    }
}
// MARK: - UIPickerView
extension Search_VC: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countriesList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: countriesList[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(countriesList[row])
        selectedCountry = countriesList[row]
        searchData(countryCode: countriesList[row])
    }
    
}
// MARK: - UITableView
extension Search_VC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return denemeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = denemeList[indexPath.row]
        return cell
    }
    
    
}
