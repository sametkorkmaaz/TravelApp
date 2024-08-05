//
//  Detail_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 11.07.2024.
//

import UIKit
import GoogleGenerativeAI
import Kingfisher


class Detail_VC: UIViewController {
    
    let url = URL(string: "https://liteapi-travel-static-data.s3.amazonaws.com/images/hotels/main/105442.jpg")!

 /*   let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    let prompt = "Sana yazdığım şehrin sadece ülke kodunu bana geri ver. Örneğin sana Ankara gönderirsem -> TR, New York gönderirsem -> US geri yaz. Bana sadece ülke kodunu geri yaz başka hiçbir açıklama yapma. Örneğin bana sadece TR yaz. Sana ülke kodunu sorduğum şehir = Antalya" */
    
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var detailBackButton: UIButton!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailPage()
        detailImageView.kf.setImage(with: url)
    }
    
    @IBAction func detailBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bookmarkButton(_ sender: Any) {
        detailImageView.kf.setImage(with: url)
       // sendMessage()
        print(url)
    }
    
    func configureDetailPage(){
        UIHelper.roundCorners(detailImageView, radius: 25)
        UIHelper.roundCorners(detailBackButton, radius: 10)
        UIHelper.addShadow(detailBackButton, renk: .gray, opaklik: 5, radius: 5, offset: CGSize(width: 5, height: 5))
    }
    
   /* func sendMessage(){
        Task{
            do{
                let response = try await model.generateContent(prompt)
                print(response)
                guard let text = response.text else{
                    print("hata")
                    return
                }
                detailTextView.text = text
            }catch {
                print("hata2")
            }
        }
        detailImageView.kf.setImage(with: url)
    } */
    
}
