//
//  AlertTableViewCell.swift
//  Forecast
//
//  Created by Ahmed on 05/08/2023.
//

import UIKit
import Lottie
import CoreLocation

class AlertTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteAnimation: LottieAnimationView!
    @IBOutlet weak var dateAndTime: UILabel!
    @IBOutlet weak var cityName: UILabel!
    var deleteThis: (()->()) = {}
    var networkIndicator = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        networkIndicator.center = self.center
        self.addSubview(networkIndicator)
        containerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 30)
        deleteAnimation.play()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        deleteAnimation.addGestureRecognizer(tap)
    }

    func setAlertData(savedAlert: SavedAlert){
        cityName.text = ""
        setCountryName(savedAlert: savedAlert)
        networkIndicator.startAnimating()
    }
    
    private func setCountryName(savedAlert: SavedAlert){
        let location = CLLocation(latitude: Double(savedAlert.lat)!, longitude: Double(savedAlert.lon)!)
        location.fetchCityAndCountry {[weak self] city, country, error in
            if city == nil {
                self?.cityName.text = "\(country ?? "")"
            }else{
                self?.cityName.text = "\(city ?? ""), \(country ?? "")"
            }
            self?.setDate(savedAlert: savedAlert)
            self?.networkIndicator.stopAnimating()
        }
    }
    
    private func setDate(savedAlert: SavedAlert){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        var dayAppendix = ""
        let day = Int(dateFormatter.string(from: savedAlert.date))
        switch day {
        case 1,21,31:
            dayAppendix = "st"
        case 2,22:
            dayAppendix = "nd"
        case 3,23:
            dayAppendix = "rd"
        default:
            dayAppendix = "th"
        }
        dateFormatter.dateFormat = "d MMMM yyyy h mm a"
        let dateString = dateFormatter.string(from: savedAlert.date)
        let dateArr = dateString.split(separator: " ")
        let displayedDate = "\(dateArr[0])\(dayAppendix) of \(dateArr[1]),\(dateArr[2])\n\(dateArr[3]):\(dateArr[4])\(dateArr[5])"
        dateAndTime.text = displayedDate
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        deleteThis()
    }
}
