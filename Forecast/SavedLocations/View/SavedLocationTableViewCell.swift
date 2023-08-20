//
//  SavedLocationTableViewCell.swift
//  Forecast
//
//  Created by Ahmed on 23/07/2023.
//

import UIKit
import Lottie
import CoreLocation

class SavedLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var deleteAnimation: LottieAnimationView!
    @IBOutlet weak var cityName: UILabel!
    var deleteThis: (()->()) = {}
    var networkIndicator = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        networkIndicator.center = self.center
        self.addSubview(networkIndicator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 30)
        deleteAnimation.play()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        deleteAnimation.addGestureRecognizer(tap)
    }
    
    func setLocationData(savedLoctaion: SavedLocation){
        cityName.text = ""
        setCountryName(savedLoctaion: savedLoctaion)
        networkIndicator.startAnimating()
    }
    
    func setCountryName(savedLoctaion: SavedLocation){
        let location = CLLocation(latitude: Double(savedLoctaion.lat)!, longitude: Double(savedLoctaion.lon)!)
        location.fetchCityAndCountry {[weak self] city, country, error in
            if city == nil {
                self?.cityName.text = "\(country ?? "")"
            }else{
                self?.cityName.text = "\(city ?? ""),\n\(country ?? "")"
            }
            self?.networkIndicator.stopAnimating()
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        deleteThis()
    }
}
