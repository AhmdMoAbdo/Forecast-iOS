//
//  OnBoardingViewController.swift
//  Forecast
//
//  Created by Ahmed on 24/07/2023.
//

import UIKit
import ImageSlideshow
import AdvancedPageControl
import MapKit
import RadioGroup
import Toast_Swift
import LanguageManager_iOS

class OnBoardingViewController: UIViewController {
    
    @IBOutlet weak var doneSelectingOnMapButton: UIButton!
    @IBOutlet weak var radioButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var alertPrevButton: UIImageView!
    @IBOutlet weak var radioGroupHeight: NSLayoutConstraint!
    @IBOutlet weak var settingsAdjustmentPageNumber: UILabel!
    @IBOutlet weak var settingsAdjustmentViewHeader: UILabel!
    @IBOutlet weak var settingsAdjustmentRadioGroup: RadioGroup!
    @IBOutlet weak var settingsAdjustmentAlertView: UIView!
    @IBOutlet weak var mapItSelf: MKMapView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var pageIndicator: AdvancedPageControlView!
    @IBOutlet weak var imageSlider: ImageSlideshow!
    let manger = CLLocationManager()
    let annotation = MKPointAnnotation()
    var selectedLocation:CLLocationCoordinate2D!
    var settingsSelectedNums: [Int] = [-1,-1,-1,-1,-1]
    let imgArr = [ImageSource(image: UIImage(named: "first") ?? UIImage()),
                  ImageSource(image: UIImage(named: "second") ?? UIImage()),
                  ImageSource(image: UIImage(named: "third") ?? UIImage()),
                  ImageSource(image: UIImage(named: "fourth") ?? UIImage())]
    let settingsArr = [["Fahrenheit","Kelvin","Celsius"],["GPS","Map"],["Miles/Hour","Meters/Sec"],["Alarm","Notification"],["English","Arabic"]]
    let settingsAlertHeaders = ["Preferred Temperature Unit", "Location Method", "Preferred Speed Unit", "Alerts Method", "Preferred Language"]
    let toastArr = ["Pick a temperature unit to continue","Pick a method to determine your location to continue", "Pick A speed unit to continue", "Pick an alert system to continue","Pick your preferred language to continue"]
    var settingsPageNumber = 1 {
        didSet{
            showCurrentSettingsAlert()
            setRadioGroupToSelectedOptionIfPrevSelected()
        }
    }
    
    func showCurrentSettingsAlert(){
        settingsAdjustmentRadioGroup.titles = settingsArr[settingsPageNumber - 1]
        settingsAdjustmentViewHeader.text = settingsAlertHeaders[settingsPageNumber - 1]
        settingsAdjustmentPageNumber.text = "\(settingsPageNumber)/5"
        if settingsPageNumber == 1 {
            alertPrevButton.isHidden = true
            radioGroupHeight.constant = 120
        }else{
            alertPrevButton.isHidden = false
            radioGroupHeight.constant = 75
        }
        adjustRadioGroupLeadingSpace()
    }
    
    func adjustRadioGroupLeadingSpace(){
        if settingsPageNumber == 1 || settingsPageNumber == 3 {
            radioButtonLeadingSpace.constant = 255/2 - 55
        }else if settingsPageNumber == 2 {
            radioButtonLeadingSpace.constant = 255/2 - 35
        }else if settingsPageNumber == 4 {
            radioButtonLeadingSpace.constant = 255/2 - 60
        }else {
            radioButtonLeadingSpace.constant = 255/2 - 45
        }
    }
    
    func setRadioGroupToSelectedOptionIfPrevSelected(){
        settingsAdjustmentRadioGroup.selectedIndex = settingsSelectedNums[settingsPageNumber - 1]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            setupUI()
    }
    
    func setupUI(){
        mapItSelf.delegate = self
        setupIndicator()
        setupImageSlider()
        setupInitialSettingsAdjustmentViewUI()
        mapContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 30)
        mapItSelf.layer.cornerRadius = 30
    }
    
    func setupIndicator(){
        pageIndicator.drawer = WormDrawer(numberOfPages: 4, height: 12, width: 12, space: 10, raduis: 16, currentItem: 0, indicatorColor: UIColor(named: "touch"), dotsColor: .clear, borderColor:.black, borderWidth: 2, indicatorBorderColor: UIColor(named: "touch")!, indicatorBorderWidth: 2)
    }
    
    func setupImageSlider(){
        imageSlider.circular = false
        imageSlider.setImageInputs(imgArr)
        imageSlider.currentPageChanged = {[weak self] pageNo in
            if pageNo == 0{
                self?.backButton.isHidden = true
            }else{
                self?.backButton.isHidden = false
            }
            self?.pageIndicator.setPage(pageNo)
        }
    }
    
    func setupInitialSettingsAdjustmentViewUI(){
        radioButtonLeadingSpace.constant = 255/2 - 55
        settingsAdjustmentAlertView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 20)
        settingsAdjustmentRadioGroup.titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        settingsAdjustmentRadioGroup.tintColor = .darkGray
        settingsAdjustmentRadioGroup.buttonSize = 16
        showCurrentSettingsAlert()
        alertPrevButton.isHidden = true
    }
    
    func showSettingsAlert(){
        curtainView.isHidden = false
        settingsAdjustmentAlertView.isHidden = false
    }

    @IBAction func getNextImage(_ sender: Any) {
        if imageSlider.currentPage < 3 {
            imageSlider.setCurrentPage(imageSlider.currentPage + 1, animated: true)
        }else{
            showSettingsAlert()
        }
    }
    
    @IBAction func getPrevImage(_ sender: Any) {
        if imageSlider.currentPage > 0 {
            imageSlider.setCurrentPage(imageSlider.currentPage - 1, animated: true)
        }
    }
    
    @IBAction func nextSetting(_ sender: UITapGestureRecognizer) {
        if(settingsAdjustmentRadioGroup.selectedIndex == -1){
            ShowErrorToast()
        }else{
            saveSettingToUserDefault()
        }
    }
    
    func ShowErrorToast(){
        var style = ToastStyle()
        style.imageSize = CGSize(width: 20, height: 20)
        style.cornerRadius = 25
        style.titleAlignment = .center
        style.verticalPadding = 15
        style.horizontalPadding = 20
        self.view.makeToast(toastArr[settingsPageNumber - 1],image: UIImage(named: "toastImage"),style: style)
    }
    
    func saveSettingToUserDefault(){
        switch settingsPageNumber {
        case 1:
            saveTemperatureSettings()
            settingsPageNumber += 1
        case 2:
            saveLocationSettings()
        case 3:
            saveSpeedSettings()
            settingsPageNumber += 1
        case 4:
            saveAlertSettings()
            settingsPageNumber += 1
        default:
            saveLanguageSettings()
            navigateToHome()
        }
    }
    
    func saveTemperatureSettings(){
        switch settingsAdjustmentRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .feh)
            settingsSelectedNums[settingsPageNumber - 1] = 0
        case 1:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .kel)
            settingsSelectedNums[settingsPageNumber - 1] = 1
        default:
            UserDefaultsManger.userDefaultHandler.saveTemperatureUnit(unit: .cel)
            settingsSelectedNums[settingsPageNumber - 1] = 2
        }
    }
    
    func saveLocationSettings(){
        switch settingsAdjustmentRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveLocationMethod(method: .gps)
            manger.requestAlwaysAuthorization()
            settingsSelectedNums[settingsPageNumber - 1] = 0
            settingsPageNumber += 1
        default:
            UserDefaultsManger.userDefaultHandler.saveLocationMethod(method: .map)
            settingsSelectedNums[settingsPageNumber - 1] = 1
            mapContainerView.isHidden = false
        }
    }
    
    func saveSpeedSettings(){
        switch settingsAdjustmentRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveSpeedUnit(unit: .mph)
            settingsSelectedNums[settingsPageNumber - 1] = 0
        default:
            UserDefaultsManger.userDefaultHandler.saveSpeedUnit(unit: .mps)
            settingsSelectedNums[settingsPageNumber - 1] = 1
        }
    }
    
    func saveAlertSettings(){
        switch settingsAdjustmentRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveAlertMethod(method: .alarm)
            settingsSelectedNums[settingsPageNumber - 1] = 0
        default:
            UserDefaultsManger.userDefaultHandler.saveAlertMethod(method: .notification)
            settingsSelectedNums[settingsPageNumber - 1] = 1
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {_,_ in }
    }
    
    func saveLanguageSettings(){
        switch settingsAdjustmentRadioGroup.selectedIndex {
        case 0:
            UserDefaultsManger.userDefaultHandler.saveLanguage(language: .en)
            settingsSelectedNums[settingsPageNumber - 1] = 0
        default:
            UserDefaultsManger.userDefaultHandler.saveLanguage(language: .ar)
            settingsSelectedNums[settingsPageNumber - 1] = 1
        }
        UserDefaultsManger.userDefaultHandler.confirmFirstTimeDone()
    }
    
    
    func navigateToHome(){
        let rootVC: (String?)->(UIViewController) = { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateInitialViewController()!
        }
        switch self.settingsSelectedNums[self.settingsPageNumber - 1] {
        case 0:
            LanguageManager.shared.setLanguage(language: .en,viewControllerFactory: rootVC)
            LanguageManager.shared.defaultLanguage = .en
        default:
            LanguageManager.shared.setLanguage(language: .ar,viewControllerFactory: rootVC)
            LanguageManager.shared.defaultLanguage = .ar
        }
    }
    
    @IBAction func prevSetting(_ sender: UITapGestureRecognizer) {
        settingsPageNumber -= 1
    }
    
    @IBAction func hideMap(_ sender: UITapGestureRecognizer) {
        mapContainerView.isHidden = true
    }
    
    @IBAction func doneSelectingLocation(_ sender: Any) {
        settingsPageNumber += 1
        UserDefaultsManger.userDefaultHandler.saveMapLocation(location: selectedLocation)
        mapContainerView.isHidden = true
        doneSelectingOnMapButton.isHidden = true
    }
    
    @IBAction func hideCurtain(_ sender: UITapGestureRecognizer) {
        curtainView.isHidden = true
        settingsAdjustmentAlertView.isHidden = true
        mapContainerView.isHidden = true
        doneSelectingOnMapButton.isHidden = true
    }
    
    @IBAction func pickedLocationOnMap(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapItSelf)
        let location = mapItSelf.convert(point , toCoordinateFrom: mapItSelf)
        annotation.coordinate = location
        mapItSelf.removeAnnotations(mapItSelf.annotations)
        mapItSelf.addAnnotation(annotation)
        doneSelectingOnMapButton.isHidden = false
        selectedLocation = location
    }
}

extension OnBoardingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let customAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        customAnnotation.image = UIImage(named: "mark")
        return customAnnotation
    }
}
