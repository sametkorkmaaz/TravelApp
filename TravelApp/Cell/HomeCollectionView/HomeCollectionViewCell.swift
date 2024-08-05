//
//  HomeCollectionViewCell.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var HomeCellObj: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UIHelper.addBorder(HomeCellObj, kalinlik: 0.2, renk: .lightGray)
        UIHelper.addShadow(HomeCellObj, renk: .gray, opaklik: 5.0, radius: 10.0, offset: CGSize(width: 5, height: 5))
        UIHelper.roundCorners(HomeCellObj, radius: 10)
        }

    }

    
