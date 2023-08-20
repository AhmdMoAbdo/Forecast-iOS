//
//  HourlyCollectionViewCell.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tempPosition: NSLayoutConstraint!
    @IBOutlet weak var hourlyImg: UIImageView!
    @IBOutlet weak var degreeType: UILabel!
    @IBOutlet weak var degreeNumber: UILabel!
    @IBOutlet weak var hour: UILabel!
    @IBOutlet weak var fullCard: UIView!
    var setup = Setup()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustTempTextPosition()
        fullCard.giveShadowAndRadius(shadowRadius: 0, cornerRadius: 30)
        contentView.layer.cornerRadius = 30
        contentView.backgroundColor = .white
        backgroundColor = .clear
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 3.3, height: 5.7)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
    }
    
    func setHourlyData(hourlyData: Current, offset: Int){
        hourlyImg.image = UIImage(named: hourlyData.weather?[0].icon ?? "dummyweather")
        let date = Date(timeIntervalSince1970: TimeInterval((hourlyData.dt! + offset - 10800)))
        hour.text = getTime(date: date)
        var temp = hourlyData.temp ?? 0.0
        adjustTempUnit(temp: &temp)
        degreeNumber.text = String(Int(temp)).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage()))
    }
    
    func getTime(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        formatter.locale =  Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())
        return formatter.string(from: date)
    }
    
    func adjustTempTextPosition(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue{
            let newConstraint = NSLayoutConstraint(item: tempPosition.firstItem!, attribute: tempPosition.firstAttribute, relatedBy: tempPosition.relation, toItem: tempPosition.secondItem, attribute: tempPosition.secondAttribute, multiplier: 0.75, constant: tempPosition.constant)
            tempPosition.isActive = false
            newConstraint.isActive = true
        }else{
            let newConstraint = NSLayoutConstraint(item: tempPosition.firstItem!, attribute: tempPosition.firstAttribute, relatedBy: tempPosition.relation, toItem: tempPosition.secondItem, attribute: tempPosition.secondAttribute, multiplier: 1.2, constant: tempPosition.constant)
            tempPosition.isActive = false
            newConstraint.isActive = true
        }
    }
    
    func adjustTempUnit(temp: inout Double){
        if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.kel.rawValue {
            temp = setup.fromCtoK(c: temp)
            degreeType.text = "K".localiz()
        }else if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.feh.rawValue {
            temp = setup.fromCtoF(c: temp)
            degreeType.text = "F".localiz()
        }else{
            degreeType.text = "C".localiz()
        }
    }
}
