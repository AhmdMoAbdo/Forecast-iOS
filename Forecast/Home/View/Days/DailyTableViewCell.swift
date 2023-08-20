//
//  DailyTableViewCell.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var degreeType: UILabel!
    @IBOutlet weak var degreeNumber: UILabel!
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var fullCard: UIView!
    @IBOutlet weak var weekDayLabelHeight: NSLayoutConstraint!
    let setup = Setup()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fullCard.giveShadowAndRadius(shadowRadius: 10, cornerRadius: 30)
        adjustHeightAndTextSize()
    }

    func adjustHeightAndTextSize(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            dayOfTheWeek.font = UIFont(name: "AlumniSansInlineOne-Regular", size: 32)
        }else{
            dayOfTheWeek.font = UIFont.boldSystemFont(ofSize: 26.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setDailyData(dayData: Daily, offset: Int){
        adjustHeightAndTextSize()
        weatherImg.image = UIImage(named: dayData.weather?[0].icon ?? "dummyweather")
        weatherDescription.text = dayData.weather?[0].description
        let currentDate = Date(timeIntervalSince1970: TimeInterval((dayData.dt! + offset - 10800)))
        dayOfTheWeek.text = currentDate.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())))
        var highTemp = dayData.temp?.max ?? 0.0
        var lowTemp = dayData.temp?.min ?? 0.0
        if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.kel.rawValue {
            highTemp = setup.fromCtoK(c: highTemp)
            lowTemp = setup.fromCtoK(c: lowTemp)
            degreeType.text = "K".localiz()
        }else if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.feh.rawValue {
            highTemp = setup.fromCtoF(c: highTemp)
            lowTemp = setup.fromCtoF(c: lowTemp)
            degreeType.text = "F".localiz()
        }else{
            degreeType.text = "C".localiz()
        }
        degreeNumber.text = "\(String(Int(highTemp)).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())))/\(String(Int(lowTemp)).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())))"
    }
    
}
