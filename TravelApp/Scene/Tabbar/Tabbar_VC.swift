//
//  Tabbar_VC.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 10.07.2024.
//

import UIKit

class Tabbar_VC: UITabBarController {
    
    @IBOutlet weak var tabbar: UITabBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.stackedLayoutAppearance.normal.iconColor = .black
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTabBarItemAppearance(selectedIndex: self.selectedIndex)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            updateTabBarItemAppearance(selectedIndex: index)
        }
    }
    
    private func updateTabBarItemAppearance(selectedIndex: Int) {
        for (index, _) in tabbar.items!.enumerated() {
            let item = tabbar.subviews[index + 1]
            if index == selectedIndex {
                addCircleBackground(to: item)
            } else {
                removeCircleBackground(from: item)
            }
        }
    }
    
    private func addCircleBackground(to view: UIView) {
        let radius: CGFloat = 35.0
        let circleLayer = CAShapeLayer()
        circleLayer.name = "circleBackground"
        circleLayer.path = UIBezierPath(roundedRect: CGRect(x: view.bounds.midX - radius - 10, y: view.bounds.midY - radius + 10, width: 2.5 * radius, height: 1.5 * radius), cornerRadius: radius).cgPath
        circleLayer.fillColor = UIColor.pick.cgColor
        view.layer.insertSublayer(circleLayer, at: 0)
    }
    
    private func removeCircleBackground(from view: UIView) {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers where layer.name == "circleBackground" {
                layer.removeFromSuperlayer()
            }
        }
    }
}



