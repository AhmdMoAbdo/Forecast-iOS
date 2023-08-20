//
//  setUp.swift
//  Forecast
//
//  Created by Ahmed on 21/07/2023.
//

import UIKit

class Setup{
    
    func setGradientBackground(colorTop: CGColor, colorBottom: CGColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        return gradientLayer
    }
    
    func setupViewControllerBackgroundGradient(me: UIViewController){
        let gradientLayer = setGradientBackground(colorTop: UIColor(named: Constants.myGrey)?.cgColor ?? UIColor.lightGray.cgColor, colorBottom: UIColor.white.cgColor)
        gradientLayer.frame = me.view.bounds
        me.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func fromCtoF(c: Double) -> Double {
        return ((c+(9.0/5.0))+32)
    }
    
    func fromCtoK(c: Double) -> Double {
        return (c + 273.15)
    }
    
    func fromMStoMH(ms: Double) -> Double {
        return (ms * 2.237)
    }
    
    class Constants{
        static let sunrise = "sunrise"
        static let sunset = "sunset"
        static let dummyPic = "dummyweather"
        static let myPurple = "customPurple"
        static let myGrey = "customGrey"
    }
}
