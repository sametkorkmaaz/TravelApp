//
//  UISegmentView.swift
//  TravelApp
//
//  Created by Samet Korkmaz on 31.07.2024.
//

import UIKit

class UISegmentView: UISegmentedControl {


}

extension UIImage{
    class func getSegRect(color: CGColor, andSize size: CGSize) -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        context?.fill(rectangle)
        
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rectangleImage!
    }
}

extension  UISegmentedControl{
    
    func removeBorder(){
        let background = UIImage.getSegRect(color: UIColor.white.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(background, for: .normal, barMetrics: .default)
        self.setBackgroundImage(background, for: .selected, barMetrics: .default)
        self.setBackgroundImage(background, for: .highlighted, barMetrics: .default)
        // Segmentler arasına dikey çizgi
        let deviderLine = UIImage.getSegRect(color: UIColor.pick.cgColor, andSize: CGSize(width: 0.0001, height: 0.00001))
        self.setDividerImage(deviderLine, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.pick.cgColor], for: .selected) 
    }
    
    func highlightSelectedSegment(){
        removeBorder()
        let lineWidth:CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let lineHeight:CGFloat = 5.0
        let lineXPosition = CGFloat(selectedSegmentIndex * Int(lineWidth))
        let lineYPosition = self.bounds.size.height
        let underLineFrame = CGRect(x: lineXPosition, y: lineYPosition, width: lineWidth, height: lineHeight)
        let underLine = UIView(frame: underLineFrame)
        underLine.backgroundColor = UIColor.pick
        underLine.tag = 1
        self.addSubview(underLine)
    }
    
    func underlinePosition(){
        guard let underLine = self.viewWithTag(1) else{ return }
        let xPositon = (self.bounds.width / CGFloat(self.numberOfSegments))*CGFloat(selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            underLine.frame.origin.x = xPositon
        })
    }
}
