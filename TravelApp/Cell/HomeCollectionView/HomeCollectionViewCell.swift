//
//  HomeCollectionViewCell.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var HomeCellObj: UIView!
    @IBOutlet weak var collectionViewImage: UIImageView!
    @IBOutlet weak var collectionViewDescriptionText: UILabel!
    @IBOutlet weak var collectionViewCategoriText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UIHelper.addBorder(HomeCellObj, kalinlik: 0.2, renk: .lightGray)
        UIHelper.addShadow(HomeCellObj, renk: .gray, opaklik: 5.0, radius: 10.0, offset: CGSize(width: 5, height: 5))
        UIHelper.roundCorners(HomeCellObj, radius: 10)
        if let customFont = UIFont(name: "Montserrat-Regular", size: 15.0) {
            //collectionViewDescriptionText.font = customFont
            collectionViewCategoriText.font = customFont
        } else {
            print("Font yüklenemedi.")
        }
    }
    func configure(with hotelData: Datum) {
        collectionViewCategoriText.text = hotelData.name
        collectionViewDescriptionText.text = hotelData.hotelDescription
        if let imageUrl = hotelData.mainPhoto, !imageUrl.isEmpty {
            collectionViewImage.kf.setImage(with: URL(string: imageUrl))
        } else {
            collectionViewImage.image = UIImage(named: "hotelPlaceholder")
        }
    }
    
}


