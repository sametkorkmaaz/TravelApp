//
//  Home_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class Home_VC: UIViewController {

    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var flights_btn: UIButton!
    @IBOutlet weak var hotels_btn: UIButton!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var home_label: UILabel!
    @IBOutlet weak var homeWelcomeText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHome()
        homeCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "flightsToList" {
            // Hedef view controller'ı al
            if let destinationVC = segue.destination as? List_VC {
                // Hedef view controller'daki değişkene değer ata
                destinationVC.viewModel = ListViewModel(kategoriTitle: "Flights")
            }
        }
        if segue.identifier == "hotelsToList" {
            // Hedef view controller'ı al
            if let destinationVC = segue.destination as? List_VC {
                // Hedef view controller'daki değişkene değer ata
                destinationVC.viewModel = ListViewModel(kategoriTitle: "Hotel")
            }
        }
    }

    func configureHome(){
        if let customFont = UIFont(name: "SourceSansPro-Black", size: 32.0) {
            homeWelcomeText.font = customFont
        } else {
            print("Font yüklenemedi.")
        }
        UIHelper.addShadow(homeImage, renk: .darkGray, opaklik: 0.5, radius: 3.0, offset: CGSize(width: 5, height: 5))
        UIHelper.addShadow(flights_btn, renk: .red, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        UIHelper.addShadow(hotels_btn, renk: .red, opaklik: 0.8, radius: 10.0, offset: CGSize(width: 5, height: 5))
        
        UIHelper.roundCorners(flights_btn, radius: 10.0)
        UIHelper.roundCorners(hotels_btn, radius: 10.0)
        
        UIHelper.addBorder(flights_btn, kalinlik: 1.0, renk: .white)
        UIHelper.addBorder(hotels_btn, kalinlik: 1.0, renk: .white)
        

    }
    
}
// MARK: - Home UICollectionView
extension Home_VC : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "homeToDetail", sender: nil)
    }
}
