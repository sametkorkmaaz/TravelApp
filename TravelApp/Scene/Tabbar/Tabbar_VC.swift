//
//  Tabbar_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit
import SnapKit

class Tabbar_VC: UITabBarController {
    
    @IBOutlet weak var tabbar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar.backgroundColor = .white
        UIHelper.addShadow(tabBar, renk: .darkGray, opaklik: 5.0, radius: 10.0, offset: CGSize(width: 5, height: 5))
        
    }

}



