//
//  ViewController.swift
//  Forecast
//
//  Created by Ahmed on 15/07/2023.
//

import UIKit
import FancyGradient
import Lottie
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var weatherConditionSpacing: NSLayoutConstraint!
    @IBOutlet weak var weatherConditionAnimation: LottieAnimationView!
    @IBOutlet weak var pageHeader: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dataAndTimeLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var cloudPercentageLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var sunsetOrRiseTime: UILabel!
    @IBOutlet weak var sunsetOrRiseText: UILabel!
    @IBOutlet weak var sunsetOrRiseImg: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var tempUnit: UILabel!
    @IBOutlet weak var tempDegreeNumber: UILabel!
    @IBOutlet weak var homeIcon: LottieAnimationView!
    @IBOutlet weak var bottomTempratureCard: UIView!
    @IBOutlet weak var topTempratureCard: FancyGradientView!
    @IBOutlet weak var dailyTableView: UITableView!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    let networkIndicator = UIActivityIndicatorView(style: .large)
    let manger = CLLocationManager()
    var forecast: Forecast!
    let setup = Setup()
    let homeViewModel = HomeViewModel(network: ApiHandler())
    let dailyHandler = DailyTableHandler(cellName: Constants.dailyCellName)
    let hourlyHandler = HourlyCollectionHandler(cellName: Constants.hourlyCellName)
    let animationArr = [DirectionAnimation(newDirection: .diagonalBottomLeftTopRight, duration: 2),
                        DirectionAnimation(newDirection: .diagonalBottomRightTopLeft, duration: 2),
                        DirectionAnimation(newDirection: .diagonalTopRightBottomLeft, duration: 2),
                        DirectionAnimation(newDirection: .diagonalTopLeftBottomRight, duration: 2)]
    var animationNum = 0
    var lat = ""
    var lon = ""
    var fromSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        positionAndAnimateActivityIndicator()
        setupInitialUI()
        setupLocationManger()
    }
    
    func setupLocationManger(){
        manger.delegate = self
        manger.desiredAccuracy = kCLLocationAccuracyBest
        manger.distanceFilter = 10
        manger.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageHeader.adjustHeaderFontSizeBasedOnLanguage()
        checkSavedOrHome()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manger.stopUpdatingLocation()
    }
    
    func checkSavedOrHome(){
        if fromSaved {
            pageHeader.text = "Saved".localiz()
            let newAnimation = LottieAnimationView(name: "bookmark")
            homeIcon.animation = newAnimation.animation
            fromSaved = false
            loadPage()
        }else{
            pageHeader.text = "Home".localiz()
            let newAnimation = LottieAnimationView(name: "home")
            homeIcon.animation = newAnimation.animation
            if UserDefaultsManger.userDefaultHandler.getLocaionMethod() == LocationMethod.gps.rawValue{
                manger.startUpdatingLocation()
            }else{
                lat = UserDefaultsManger.userDefaultHandler.getMapLocaiton().0
                lon = UserDefaultsManger.userDefaultHandler.getMapLocaiton().1
                loadPage()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = String(locations.last?.coordinate.latitude ?? 30.0444)
        lon = String(locations.last?.coordinate.longitude ?? 31.2357)
        loadPage()
        UserDefaultsManger.userDefaultHandler.saveMapLocation(location: locations.last?.coordinate ?? CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357))
        manger.stopUpdatingLocation()
    }
    
    func loadPage(){
        hideOrShowUI(hide: true)
        networkIndicator.startAnimating()
        animateHomeIcon(self)
        getWeatherDataFromVM()
    }
        
    func hideOrShowUI(hide: Bool){
        scrollView.isHidden = hide
        countryNameLabel.isHidden = hide
        dataAndTimeLabel.isHidden = hide
        weatherConditionAnimation.isHidden = hide
    }
    
    func positionAndAnimateActivityIndicator(){
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
        networkIndicator.startAnimating()
    }
    
    func setupInitialUI(){
        setup.setupViewControllerBackgroundGradient(me: self)
        setUpHourlyCollectionNib()
        setUpDailyTableNib()
        setupDailyTableDelegates()
        setuphourlyCollectionDelegates()
        setUpTopCard()
        bottomTempratureCard.giveShadowAndRadius(shadowRadius: 10, cornerRadius: 30)
        homeIcon.play()
        weatherConditionAnimation.loopMode = .loop
        hideOrShowUI(hide: true)
    }
    
    func setUpHourlyCollectionNib(){
        let cellNib = UINib(nibName: Constants.hourlyClassName, bundle: nil)
        hourlyCollectionView.register(cellNib, forCellWithReuseIdentifier: Constants.hourlyCellName)
    }
    
    func setUpDailyTableNib(){
        let cellNib = UINib(nibName: Constants.dailyClassName, bundle: nil)
        dailyTableView.register(cellNib, forCellReuseIdentifier: Constants.dailyCellName)
    }
    
    func setupDailyTableDelegates(){
        dailyTableView.dataSource = dailyHandler
        dailyTableView.delegate = dailyHandler
    }
    
    func setuphourlyCollectionDelegates(){
        hourlyCollectionView.dataSource = hourlyHandler
        hourlyCollectionView.delegate = hourlyHandler
    }
    
    func setUpTopCard(){
        topTempratureCard.colors = [UIColor(named: Constants.myPurple) ?? UIColor.purple, UIColor.white]
        let myCustomAnimation = CustomAnimation()
                    .then(animationArr[animationNum])
        topTempratureCard.animate(animation: myCustomAnimation)
        topTempratureCard.giveShadowAndRadius(shadowRadius: 10, cornerRadius: 30)
    }
    
    func getWeatherDataFromVM(){
        homeViewModel.getHomeData(lat: lat,lon: lon ) {[weak self] currentForecast in
            self?.forecast = currentForecast
            self?.setCountryName()
        }
    }
    
    func setCountryName(){
        let location = CLLocation(latitude: forecast.lat!, longitude: forecast.lon!)
        location.fetchCityAndCountry {[weak self] city, country, error in
            if city == nil {
                self?.countryNameLabel.text = "\(country ?? "")"
            }else{
                self?.countryNameLabel.text = "\(city ?? ""), \(country ?? "")"
            }
            self?.setRetrievedDataToUI()
        }
    }
    
    func setRetrievedDataToUI(){
        setBackGroundAnimation()
        setDateAndTime()
        setTopCardData()
        setHourlyData()
        setDailyTableData()
        setBottomCardData()
        networkIndicator.stopAnimating()
        hideOrShowUI(hide: false)
        animateGradient(self)
        weatherConditionAnimation.play()
    }
    
    func setBackGroundAnimation(){
        weatherConditionAnimation.alpha = 1
        if forecast.current?.weather?[0].description?.contains("snow") ?? false{
            let backgroundAnimation = LottieAnimationView(name: "snow")
            weatherConditionAnimation.animation = backgroundAnimation.animation
        }else if forecast.current?.weather?[0].description?.contains("rain") ?? false{
            let backgroundAnimation = LottieAnimationView(name: "rain")
            weatherConditionAnimation.animation = backgroundAnimation.animation
        }else{
            weatherConditionAnimation.alpha = 0
        }
    }
    
    func setDateAndTime(){
        let currentDate = Date(timeIntervalSince1970: TimeInterval(((forecast.current?.dt!)! + forecast.timezoneOffset! - 10800)))
        let formatter = DateFormatter()
        formatter.dateFormat = UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue ? "E:dd-MMM-yyyy '\n' h:mm a" : "EEEE:dd-MMM-yyyy '\n' h:mm a"
        formatter.locale =  Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())
        let dateString = formatter.string(from: currentDate)
        dataAndTimeLabel.text = dateString
    }
    
    func setTopCardData(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            weatherConditionSpacing.constant = 15
        }else{
            weatherConditionSpacing.constant = -15
        }
        var temp = forecast.current?.temp ?? 0.0
        if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.kel.rawValue {
            temp = setup.fromCtoK(c: temp)
            tempUnit.text = "K".localiz()
        }else if UserDefaultsManger.userDefaultHandler.getTemperatureUnit() == TemperatureUnit.feh.rawValue {
            temp = setup.fromCtoF(c: temp)
            tempUnit.text = "F".localiz()
        }else{
            tempUnit.text = "C".localiz()
        }
        if UserDefaultsManger.userDefaultHandler.getLanguage() == "en"{
            tempDegreeNumber.text = String(Int(temp))
        }else{
            tempDegreeNumber.font = UIFont.systemFont(ofSize: 40)
            tempDegreeNumber.text = String(Int(temp)).convertedDigitsToLocale(Locale(identifier: "ar"))
            tempUnit.font = UIFont.systemFont(ofSize: 30)
        }
        weatherDescription.text = forecast.current?.weather?[0].description ?? ""
        currentWeatherImage.image = UIImage(named: forecast.current?.weather?[0].icon ?? Constants.dummyPic)
        setupSunRiseOrSet()
    }
    
    func setupSunRiseOrSet(){
        if forecast.current?.sunrise == nil || forecast.current?.sunset == nil {
            
        }
        else{
            if (forecast.current?.dt!)! < (forecast.current?.sunrise ?? 0)! {
                sunsetOrRiseText.text = Constants.sunrise.localiz()
                sunsetOrRiseImg.image = UIImage(named: Constants.sunriseWord)
                let nextEventDate = Date(timeIntervalSince1970: TimeInterval(((forecast.current?.sunrise!)! + forecast.timezoneOffset! - 10800)))
                sunsetOrRiseTime.text = getTime(date: nextEventDate)
            }else if (forecast.current?.dt!)! >= (forecast.current?.sunset!)! {
                sunsetOrRiseText.text = Constants.sunrise.localiz()
                sunsetOrRiseImg.image = UIImage(named: Constants.sunriseWord)
                let nextEventDate = Date(timeIntervalSince1970: TimeInterval((((forecast.daily?[1].sunrise!)!) + forecast.timezoneOffset! - 10800)))
                sunsetOrRiseTime.text = getTime(date: nextEventDate)
            }else {
                sunsetOrRiseText.text = Constants.sunset.localiz()
                sunsetOrRiseImg.image = UIImage(named: Constants.sunsetWord)
                let nextEventDate = Date(timeIntervalSince1970: TimeInterval(((forecast.current?.sunset!)! + forecast.timezoneOffset! - 10800)))
                sunsetOrRiseTime.text = nextEventDate.formatted(date: .omitted, time: .complete)
                sunsetOrRiseTime.text = getTime(date: nextEventDate)
            }
        }
    }
    
    func getTime(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale =  Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())
        return formatter.string(from: date)
    }
    
    func setHourlyData(){
        hourlyHandler.hourlyDataArr = forecast.hourly ?? []
        hourlyHandler.hourlyDataArr.remove(at: 0)
        hourlyHandler.offset = forecast.timezoneOffset ?? 0
        hourlyCollectionView.reloadData()
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            hourlyCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .right, animated: true)
        }else{
            hourlyCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        }
    }
    
    func setDailyTableData(){
        dailyHandler.dailyDataArr = forecast.daily ?? []
        dailyHandler.dailyDataArr.remove(at: 0)
        dailyHandler.offset = forecast.timezoneOffset ?? 0
        dailyTableView.reloadData()
    }
    
    func setBottomCardData(){
        if UserDefaultsManger.userDefaultHandler.getSpeedUnit() == SpeedUnit.mps.rawValue {
            let unit = "M/S".localiz()
            windSpeed.text = "\(forecast.current?.windSpeed ?? 0.0) \(unit)".convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage()))
        }else {
            let unit = "M/H".localiz()
            windSpeed.text = "\(String(format: "%.2f", setup.fromMStoMH(ms: forecast.current?.windSpeed ?? 0.0)).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage()))) \(unit)"
        }
        humidityLabel.text = "\(String(forecast.current?.humidity ?? 0).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())))" + " %".localiz()
        cloudPercentageLabel.text = "\(String(forecast.current?.clouds ?? 0).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())))" + " %".localiz()
        visibilityLabel.text = "\(String(forecast.current?.visibility ?? 0).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage()))) "+"M".localiz()
        pressureLabel.text = String(forecast.current?.pressure ?? 0).convertedDigitsToLocale(Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())) + " hpa".localiz()
    }
    
    @IBAction func animateGradient(_ sender: Any) {
        if animationNum != 3 {
            animationNum += 1
            let myCustomAnimation = CustomAnimation()
                        .then(animationArr[animationNum])
            topTempratureCard.animate(animation: myCustomAnimation)
        }else{
            animationNum = 0
            let myCustomAnimation = CustomAnimation()
                        .then(animationArr[animationNum])
            topTempratureCard.animate(animation: myCustomAnimation)
        }
    }
    
    @IBAction func animateHomeIcon(_ sender: Any) {
        homeIcon.play()
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let settings = self.storyboard?.instantiateViewController(identifier: "settings") as! SettingsViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
        checkSavedOrHome()
    }
}

extension ViewController {
    class Constants{
        static let hourlyCellName = "hour"
        static let hourlyClassName = "HourlyCollectionViewCell"
        static let dailyCellName = "day"
        static let dailyClassName = "DailyTableViewCell"
        static let sunrise = "Sunrise"
        static let sunriseWord = "sunrise"
        static let sunset = "Sunset"
        static let sunsetWord = "sunset"
        static let dummyPic = "dummyweather"
        static let myPurple = "customPurple"
        static let myGrey = "customGrey"
    }
}


