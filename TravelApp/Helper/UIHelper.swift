//
//  UIHelper.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class UIHelper {

    // BORDER EKLEYEN BİR FONKSİYON YAZDIK
    static func addBorder(_ view: UIView, kalinlik: CGFloat, renk: UIColor) {
        // Kullanıcıdan alınan UIColor nesnesini CGColor'a dönüştürme
        let borderRenk = renk.cgColor
        
        view.layer.borderWidth = kalinlik
        view.layer.borderColor = borderRenk
    }

    // GÖLGE EKLEYEN BİR FONSKİYON YAZDIK
    static func addShadow(_ view: UIView, renk: UIColor, opaklik: CGFloat, radius: CGFloat, offset: CGSize) {
        // Kullanıcıdan alınan UIColor nesnesini CGColor'a dönüştürme
        let shadowRenk = renk.cgColor
        
        view.layer.shadowColor = shadowRenk
        view.layer.shadowOpacity = Float(opaklik)
        view.layer.shadowRadius = radius
        view.layer.shadowOffset = offset
        view.layer.masksToBounds = false
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    // KÖŞELERİ YUVARLAKLAŞTIRAN BİR FONKSİYON YAZDIK
    static func roundCorners(_ view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }
}
