//
//  SettingsViewController.swift
//  Forecast
//
//  Created by Ahmed on 22/07/2023.
//

import UIKit
import Lottie
import RadioGroup
import MapKit
import LanguageManager_iOS

class SettingsViewController: UIViewController {

    @IBOutlet weak var celBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var kelvinTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var CUnitLabel: UILabel!
    @IBOutlet weak var FUnitLabel: UILabel!
    @IBOutlet weak var kUnitLabel: UILabel!
    @IBOutlet weak var mpsLabel: UILabel!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var speedBoxHeader: UILabel!
    @IBOutlet weak var languageBoxHeader: UILabel!
    @IBOutlet weak var temperatureBoxHeader: UILabel!
    @IBOutlet weak var alertsBoxHeader: UILabel!
    @IBOutlet weak var locationBoxHeader: UILabel!
    @IBOutlet weak var pageHeader: UILabel!
    @IBOutlet weak var pickLocationButton: UIButton!
    @IBOutlet weak var saveCurrentSettingsButton: UIButton!
    @IBOutlet weak var doneSelectingLocationButton: UIButton!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapItSelf: MKMapView!
    @IBOutlet weak var speedRadioGroup: RadioGroup!
    @IBOutlet weak var speedSelectionView: UIView!
    @IBOutlet weak var languageRadioGroup: RadioGroup!
    @IBOutlet weak var languageSelectionView: UIView!
    @IBOutlet weak var temperatureRadioGroup: RadioGroup!
    @IBOutlet weak var temperatureSelectionView: UIView!
    @IBOutlet weak var alertRadioGroup: RadioGroup!
    @IBOutlet weak var alertSelectionView: UIView!
    @IBOutlet weak var locationsRadioGroup: RadioGroup!
    @IBOutlet weak var locationSelectionView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var settingsAnimation: LottieAnimationView!
    let annotation = MKPointAnnotation()
    var selectedLocation = CLLocationCoordinate2D(latitude: Double(UserDefaultsManger.userDefaultHandler.getMapLocaiton().0 ) ?? 30.0444, longitude: Double(UserDefaultsManger.userDefaultHandler.getMapLocaiton().1 ) ?? 31.2357)
    let manger = CLLocationManager()
    var savedSettingsArr = [-1,-1,-1,-1,-1]
    let setup = Setup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        adjustLabelNames()
        adjustLabelSizes()
        adjustUnitsConstarint()
        pageHeader.adjustHeaderFontSizeBasedOnLanguage()
        setupUI()
        if self.tabBarController?.selectedIndex == 1 {
            homeButton.imageView?.layer.opacity = 1
        }else {
            homeButton.imageView?.layer.opacity = 0.5
        }
        settingsAnimation.play()
        setup.setupViewControllerBackgroundGradient(me: self)
    }
    
    func setupUI(){
        setupPickLocationButton()
        setupLocationView()
        setupAlertView()
        setupTemperatureView()
        setupLanguageView()
        setupSpeedView()
        setupMap()
    }
    
    func setupPickLocationButton(){
        let path = UIBezierPath(roundedRect:pickLocationButton.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 10, height:  10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        pickLocationButton.layer.mask = maskLayer
    }
    
    func setupLocationView(){
        locationsRadioGroup.titles = ["GPS".localiz(),"Map".localiz()]
        setupRadioGroupUI(myRadioGroup: locationsRadioGroup, containerView: locationSelectionView)
        locationsRadioGroup.addTarget(self, action: #selector(newSelection), for: .valueChanged)
        switch UserDefaultsManger.userDefaultHandler.getLocaionMethod() {
        case LocationMethod.gps.rawValue:
            savedSettingsArr[0] = 0
            locationsRadioGroup.selectedIndex = 0
            pickLocationButton.isHidden = true
        default:
            savedSettingsArr[0] = 1
            locationsRadioGroup.selectedIndex = 1
            pickLocationButton.isHidden = false
        }
    }
    
    func setupAlertView(){
        alertRadioGroup.titles = ["Notification".localiz(),"Alarm".localiz()]
        setupRadioGroupUI(myRadioGroup: alertRadioGroup, containerView: alertSelectionView)
        alertRadioGroup.addTarget(self, action: #selector(newSelection), for: .valueChanged)
        switch UserDefaultsManger.userDefaultHandler.getAlertMethod() {
        case AlertMehod.notification.rawValue:
            savedSettingsArr[1] = 0
            alertRadioGroup.selectedIndex = 0
        default:
            savedSettingsArr[1] = 1
            alertRadioGroup.selectedIndex = 1
        }
    }
    
    func setupTemperatureView(){
        temperatureRadioGroup.titles = ["Kelvin".localiz(),"Fahrenheit".localiz(),"Celsius".localiz()]
        setupRadioGroupUI(myRadioGroup: temperatureRadioGroup, containerView: temperatureSelectionView)
        temperatureRadioGroup.addTarget(self, action: #selector(newSelection), for: .valueChanged)
        switch UserDefaultsManger.userDefaultHandler.getTemperatureUnit() {
        case TemperatureUnit.kel.rawValue:
            temperatureRadioGroup.selectedIndex = 0
            savedSettingsArr[2] = 0
        case TemperatureUnit.feh.rawValue:
            temperatureRadioGroup.selectedIndex = 1
            savedSettingsArr[2] = 1
        default:
            temperatureRadioGroup.selectedIndex = 2
            savedSettingsArr[2] = 2
        }
    }
    
    func setupSpeedView(){
        speedRadioGroup.titles = ["Miles\n/Hour".localiz(),"Meters\n/Sec".localiz()]
        setupRadioGroupUI(myRadioGroup: speedRadioGroup, containerView: speedSelectionView)
        speedRadioGroup.addTarget(self, action: #selector(newSelection), for: .valueChanged)
        switch UserDefaultsManger.userDefaultHandler.getSpeedUnit() {
        case SpeedUnit.mph.rawValue:
            speedRadioGroup.selectedIndex = 0
            savedSettingsArr[3] = 0
        default:
            speedRadioGroup.selectedIndex = 1
            savedSettingsArr[3] = 1
        }
    }
    
    func setupLanguageView(){
        languageRadioGroup.titles = ["English".localiz(),"Arabic".localiz()]
        setupRadioGroupUI(myRadioGroup: languageRadioGroup, containerView: languageSelectionView)
        languageRadioGroup.addTarget(self, action: #selector(newSelection), for: .valueChanged)
        switch UserDefaultsManger.userDefaultHandler.getLanguage() {
        case LanguageType.en.rawValue:
            languageRadioGroup.selectedIndex = 0
            savedSettingsArr[4] = 0
        default:
            languageRadioGroup.selectedIndex = 1
            savedSettingsArr[4] = 1
        }
    }
    
    @objc func newSelection(){
        if locationsRadioGroup.selectedIndex == savedSettingsArr[0] &&
            alertRadioGroup.selectedIndex == savedSettingsArr[1] &&
            temperatureRadioGroup.selectedIndex == savedSettingsArr[2] &&
            speedRadioGroup.selectedIndex == savedSettingsArr[3] &&
            languageRadioGroup.selectedIndex == savedSettingsArr[4] {
            saveCurrentSettingsButton.isHidden = true
        }else{
            saveCurrentSettingsButton.isHidden = false
        }
        
        if locationsRadioGroup.selectedIndex == 1 {
            pickLocationButton.isHidden = false
        }else{
            pickLocationButton.isHidden = true
        }
    }
    
    func setupMap(){
        mapContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 30)
        mapItSelf.layer.cornerRadius = 30
        mapItSelf.delegate = self
    }
    
    func setupRadioGroupUI(myRadioGroup: RadioGroup, containerView: UIView){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.ar.rawValue{
            myRadioGroup.isButtonAfterTitle = true
            myRadioGroup.titleAlignment = .right
        }else{
            myRadioGroup.isButtonAfterTitle = false
            myRadioGroup.titleAlignment = .left
        }
        containerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 35)
        myRadioGroup.titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        myRadioGroup.tintColor = .darkGray
        myRadioGroup.buttonSize = 16
    }
    
    func saveTemperatureSettings(){
        switch temperatureRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .kel)
        case 1:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .feh)
        default:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .cel)
        }
    }
    
    func saveSettings(){
        saveLocationSettings()
        saveAlertSettings()
        saveTemperatureSettings()
        saveSpeedSettings()
        saveLanguageSettings()
    }
    
    func saveLocationSettings(){
        switch locationsRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveLocationMethod(method: .gps)
            manger.requestAlwaysAuthorization()
        default:
            UserDefaultsManger.userDefaultHandler.saveLocationMethod(method: .map)
            UserDefaultsManger.userDefaultHandler.saveMapLocation(location: selectedLocation)
        }
    }
    
    func saveSpeedSettings(){
        switch speedRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveSpeedUnit(unit: .mph)
        default:
            UserDefaultsManger.userDefaultHandler.saveSpeedUnit(unit: .mps)
        }
    }
    
    func saveAlertSettings(){
        switch alertRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveAlertMethod(method: .notification)
        default:
            UserDefaultsManger.userDefaultHandler.saveAlertMethod(method: .alarm)
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {_,_ in }
    }
    
    func saveLanguageSettings(){
        switch languageRadioGroup.selectedIndex {
        case 0:
            if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.ar.rawValue{
                UserDefaultsManger.userDefaultHandler.saveLanguage(language: .en)
                let rootVC: (String?)->(UIViewController) = { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    return storyboard.instantiateInitialViewController()!
                }
                LanguageManager.shared.setLanguage(language: .en,viewControllerFactory: rootVC)
                LanguageManager.shared.defaultLanguage = .en
            }
        default:
            if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue{
                UserDefaultsManger.userDefaultHandler.saveLanguage(language: .ar)
                let rootVC: (String?)->(UIViewController) = { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    return storyboard.instantiateInitialViewController()!
                }
                LanguageManager.shared.setLanguage(language: .ar,viewControllerFactory: rootVC)
                LanguageManager.shared.defaultLanguage = .ar
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func doneSelectingLocationOnMap(_ sender: Any) {
        mapContainerView.isHidden = true
        curtainView.isHidden = true
        doneSelectingLocationButton.isHidden = true
        saveCurrentSettingsButton.isHidden = false
        mapItSelf.removeAnnotations(mapItSelf.annotations)
    }
    
    @IBAction func selectedLocationOnMap(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapItSelf)
        let location = mapItSelf.convert(point , toCoordinateFrom: mapItSelf)
        annotation.coordinate = location
        mapItSelf.removeAnnotations(mapItSelf.annotations)
        mapItSelf.addAnnotation(annotation)
        doneSelectingLocationButton.isHidden = false
        selectedLocation = location
    }
    
    @IBAction func pickLocationButtonPressed(_ sender: Any) {
        curtainView.isHidden = false
        mapContainerView.isHidden = false
    }
    
    @IBAction func saveCurrentSettingsbuttonClicked(_ sender: Any) {
        saveSettings()
        setupUI()
        saveCurrentSettingsButton.isHidden = true
    }
    @IBAction func exitMapButtonClicked(_ sender: UITapGestureRecognizer) {
        mapContainerView.isHidden = true
        curtainView.isHidden = true
        doneSelectingLocationButton.isHidden = true
        mapItSelf.removeAnnotations(mapItSelf.annotations)
    }
}

extension SettingsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let customAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        customAnnotation.image = UIImage(named: "mark")
        return customAnnotation
    }
}

extension SettingsViewController {
    
    func adjustLabelSizes(){
        adjustLabel(label: locationBoxHeader, type: "header")
        adjustLabel(label: alertsBoxHeader, type: "header")
        adjustLabel(label: temperatureBoxHeader, type: "header")
        adjustLabel(label: speedBoxHeader, type: "header")
        adjustLabel(label: languageBoxHeader, type: "header")
        adjustLabel(label: kUnitLabel, type: "tempUnit")
        adjustLabel(label: FUnitLabel, type: "tempUnit")
        adjustLabel(label: CUnitLabel, type: "tempUnit")
        adjustLabel(label: mphLabel, type: "speed")
        adjustLabel(label: mpsLabel, type: "speed")
    }
    
    func adjustLabel(label: UILabel, type: String){
        if type == "header"{
            if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
                label.font = label.font.withSize(30)
            }else{
                label.font = label.font.withSize(25)
            }
        }else if type == "tempUnit"{
            if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
                label.font = label.font.withSize(30)
            }else{
                label.font = label.font.withSize(18)
            }
        }else{
            if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
                label.font = label.font.withSize(21)
            }else{
                label.font = label.font.withSize(18)
            }
        }
    }
    
    func adjustUnitsConstarint(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            kelvinTopConstraint.constant = 0
            celBottomConstraint.constant = 0
        }else{
            kelvinTopConstraint.constant = 7
            celBottomConstraint.constant = -7
        }
    }
    
    func adjustLabelNames(){
        locationBoxHeader.text = "Location".localiz()
        alertsBoxHeader.text = "Alerts".localiz()
        temperatureBoxHeader.text = "Temperature".localiz()
        speedBoxHeader.text = "Speed".localiz()
        languageBoxHeader.text = "Language".localiz()
        kUnitLabel.text = "K".localiz()
        FUnitLabel.text = "F".localiz()
        CUnitLabel.text = "C".localiz()
        mphLabel.text = "M/H".localiz()
        mpsLabel.text = "M/S".localiz()
    }
}
