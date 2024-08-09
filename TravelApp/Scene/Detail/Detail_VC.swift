//
//  Detail_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 11.07.2024.
//

import UIKit
import GoogleGenerativeAI
import Kingfisher

protocol DetailViewInterface {
    func configureDetailPage()
    func configureDetailBookmarkButtonText()
}

class Detail_VC: UIViewController {
    
    var viewModel: DetailViewModelInterface!
    
    var detailText: String = "?"
    var detailTitleText: String = "?"
    var detailImageUrl: String = "?"
    var detailCategoriText: String = "?"
    var detailHotelStarCount = 0
    var detailBookmarkButtonText: String = "?"
    
    @IBOutlet weak var detailHotelStars: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var detailBackButton: UIButton!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailCategories: UILabel!
    @IBOutlet weak var detailBookmarkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DetailViewModel(view: self)
        viewModel.viewDidLoad()
    }
    
    @IBAction func detailBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bookmarkButton(_ sender: Any) {
        viewModel.detailBookmarkButton()
        
    }
    
}

extension Detail_VC: DetailViewInterface{
    
    func configureDetailPage(){
        
        if let customFont = UIFont(name: "Montserrat-Light", size: 16.0) {
            detailTextView.font = customFont
        } else {
            print("Font yüklenemedi.")
        }
        
        if let customFont = UIFont(name: "Montserrat-Regular", size: 20.0) {
            detailTitle.font = customFont
        } else {
            print("Font yüklenemedi.")
        }
        
        if let customFont = UIFont(name: "Montserrat-Regular", size: 20.0) {
            detailBookmarkButton.titleLabel?.font = customFont
        } else {
            print("Font yüklenemedi bookmark.")
        }
        UIHelper.roundCorners(detailImageView, radius: 25)
        UIHelper.roundCorners(detailBackButton, radius: 10)
        UIHelper.addShadow(detailBackButton, renk: .gray, opaklik: 5, radius: 5, offset: CGSize(width: 5, height: 5))
        UIHelper.roundCorners(detailBookmarkButton, radius: 10)
        
        if detailImageUrl.range(of: "bstatic") != nil || detailImageUrl == ""{
            detailImageView.image = UIImage(named: "splash")
        } else {
            detailImageView.kf.setImage(with: URL(string: detailImageUrl))
        }
        
        detailTextView.text = detailText
        detailTitle.text = detailTitleText
        detailCategories.text = detailCategoriText
        detailHotelStars.text = String(repeating: "⭐️", count: detailHotelStarCount)
        detailBookmarkButton.setTitle(detailBookmarkButtonText, for: .normal)
    }
    
    func configureDetailBookmarkButtonText() {
        if detailBookmarkButton.title(for: .normal) == "Add Bookmark" {
            detailBookmarkButton.setTitle("Remove Bookmark", for: .normal)
            // Add bookmark işlemi burada yapılacak
        } else {
            detailBookmarkButton.setTitle("Add Bookmark", for: .normal)
            // Remove bookmark işlemi burada yapılacak
        }
    }
    
}
