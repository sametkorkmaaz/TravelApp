//
//  AllTableViewCell.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 21.07.2024.
//

import UIKit

protocol BookmarkButtonDelegate: AnyObject {
    func bookmarkButtonTapped(on cell: AllTableViewCell)
}

class AllTableViewCell: UITableViewCell {
    
    var isBookmarkFilled = false
    
    @IBOutlet weak var cellCategory: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDescription: UILabel!
    @IBOutlet weak var cellCountryFlag: UIImageView!
    @IBOutlet weak var hotelStarCount: UILabel!
    
    @IBOutlet weak var cellBookmarkButton: UIButton!
    
    weak var delegate: BookmarkButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func cellBookmarkButton(_ sender: Any) {
        delegate?.bookmarkButtonTapped(on: self)
        if isBookmarkFilled {
            // Eğer kalp doluysa, dolu olmayan haline geri dön ve favorilerden sil
            cellBookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            
        } else {
            // Eğer kalp dolu değilse, dolu haline getir
            cellBookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            
        }
        // Durumu tersine çevir
        isBookmarkFilled = !isBookmarkFilled
    }
    
}
