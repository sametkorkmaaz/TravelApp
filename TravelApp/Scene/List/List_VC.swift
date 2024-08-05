//
//  List_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 11.07.2024.
//

import UIKit

class List_VC: UIViewController {

    var kategoriTitle : String = "?"
    @IBOutlet weak var kategoriTitle_lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        kategoriTitle_lbl.text = kategoriTitle
    }
    

    @IBAction func listViewBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
