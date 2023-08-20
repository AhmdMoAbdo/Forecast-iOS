//
//  AlertsViewController.swift
//  Forecast
//
//  Created by Ahmed on 22/07/2023.
//

import UIKit
import Lottie
import MapKit

class AlertsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var mapDoneButton: UIButton!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var datePickerItSelf: UIDatePicker!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var mapItself: MKMapView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var pageHeader: UILabel!
    @IBOutlet weak var alertsTable: UITableView!
    @IBOutlet weak var noAlertsView: UIView!
    @IBOutlet weak var bellAnimation: LottieAnimationView!
    var center = UNUserNotificationCenter.current()
    var selectedLocation: CLLocationCoordinate2D!
    let annotation = MKPointAnnotation()
    var notificationTitle = ""
    var notificationBody = ""
    let networkIndicator = UIActivityIndicatorView(style: .large)
    let alertViewModel = AlertsViewModel(network: ApiHandler(),localSource: ConcreteLocalSource())
    var selectedDate:Date!
    var alertPresent = false
    var itemTobeDeleteIndexPath: IndexPath!
    var doneRetrievingAllData = 0{
        didSet{
            if doneRetrievingAllData == 2 {
                showOrHideDatePickerView(hide: true)
                showOrHideMapView(hide: true)
                mapDoneButton.isHidden = true
                mapItself.removeAnnotations(mapItself.annotations)
                networkIndicator.stopAnimating()
                if alertPresent {
                    notificationTitle = locationName
                }else{
                    notificationBody = notificationBody + locationName
                }
                let alert = SavedAlert(value: ["lon": String(selectedLocation.longitude)])
                alert.lat = String(selectedLocation.latitude)
                alert.locationName = locationName
                alert.date = selectedDate
                print("\(alert.lat).....\(alert.lat)")
                print("\(selectedLocation.longitude).....\(selectedLocation.latitude)")
                if alertViewModel.checkIfAlertIsNew(alertInQuestion: alert){
                    setNotification()
                    alertViewModel.addAnotherAlert(alertToBeAdded: alert)
                    alertViewModel.savedAlerts.append(alert)
                    checkWhichViewToShowOrHide()
                    alertsTable.reloadData()
                }
            }
        }
    }
    var locationName = ""
    let setup = Setup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        setupNib()
        center.delegate = self
        mapItself.delegate = self
        datePickerItSelf.minimumDate = Date()
        mapContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 20)
        dateContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 20)
        alertView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 20)
        mapItself.layer.cornerRadius = 20
        setup.setupViewControllerBackgroundGradient(me: self)
        setupActivityIndicator()
        handleReturnedSavedAlerts()
    }
    
    func handleReturnedSavedAlerts(){
        alertViewModel.doneGettingAlerts = {[weak self] in
            self?.checkWhichViewToShowOrHide()
            self?.networkIndicator.stopAnimating()
        }
    }
    
    func checkWhichViewToShowOrHide(){
        if alertViewModel.savedAlerts.isEmpty {
            noAlertsView.isHidden = false
            alertsTable.isHidden = true
        }else{
            noAlertsView.isHidden = true
            alertsTable.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageHeader.adjustHeaderFontSizeBasedOnLanguage()
        bellAnimation.play()
        showOrHideMapView(hide: true)
        showOrHideDatePickerView(hide: true)
        showOrHideAlert(hide: true)
        mapDoneButton.isHidden = true
        networkIndicator.startAnimating()
        alertViewModel.getSavedAlerts()
    }
    
    func showOrHideMapView(hide: Bool){
        curtainView.isHidden = hide
        mapContainerView.isHidden = hide
    }
    
    func setupActivityIndicator(){
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
    }
    
    func showOrHideDatePickerView(hide: Bool){
        curtainView.isHidden = hide
        dateContainerView.isHidden = hide
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let settings = self.storyboard?.instantiateViewController(identifier: "settings") as! SettingsViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    @IBAction func dateOkButtonClicked(_ sender: Any) {
        selectedDate = datePickerItSelf.date
        dateContainerView.isHidden = true
        mapContainerView.isHidden = false
    }
    
    @IBAction func dateCancelButtonClicked(_ sender: Any) {
        showOrHideDatePickerView(hide: true)
    }
    
    @IBAction func addNewAlertButtonClicked(_ sender: Any) {
        showOrHideDatePickerView(hide: false)
    }
    
    @IBAction func exitMapButtonClicked(_ sender: UITapGestureRecognizer) {
        showOrHideDatePickerView(hide: true)
        showOrHideMapView(hide: true)
        mapDoneButton.isHidden = true
    }
    
    @IBAction func doneSelectingLocationOnMap(_ sender: UIButton) {
        networkIndicator.startAnimating()
        setCountryName()
        getAlertData()
    }
    
    func setCountryName(){
        let location = CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
        location.fetchCityAndCountry {[weak self] city, country, error in
            if city == nil {
                self?.locationName = "\(country ?? "")"
            }else{
                self?.locationName = "\(city ?? ""), \(country ?? "")"
            }
            self?.doneRetrievingAllData += 1
        }
    }
    
    func getAlertData(){
        alertViewModel.getAlertData(lat: String(selectedLocation.latitude), lon: String(selectedLocation.longitude)) {[weak self] incomingForecast in
            if incomingForecast.alerts?.isEmpty ?? true {
                self?.alertPresent = false
                self?.notificationTitle = "All safe"
                self?.notificationBody = "There are no weather Alerts in "
            }else{
                self?.notificationBody = incomingForecast.alerts?[0].description ?? ""
                self?.alertPresent = true
            }
            self?.doneRetrievingAllData += 1
        }
    }
    
    @IBAction func longPressedLocationOnMap(_ sender: UILongPressGestureRecognizer) {
        mapDoneButton.isHidden = false
        let point = sender.location(in: mapItself)
        let location = mapItself.convert(point , toCoordinateFrom: mapItself)
        annotation.coordinate = location
        mapItself.removeAnnotations(mapItself.annotations)
        mapItself.addAnnotation(annotation)
        mapDoneButton.isEnabled = true
        selectedLocation = location
    }
    
    @IBAction func cancelDeleteAlert(_ sender: Any) {
        showOrHideAlert(hide: true)
    }
    
    @IBAction func confirmDeleteAlert(_ sender: Any) {
        alertViewModel.deleteAlert(alertToBeDeleted: alertViewModel.savedAlerts[itemTobeDeleteIndexPath.row])
        alertViewModel.savedAlerts.remove(at: itemTobeDeleteIndexPath.row)
        alertsTable.deleteRows(at: [itemTobeDeleteIndexPath], with: .left)
        checkWhichViewToShowOrHide()
        showOrHideAlert(hide: true)
    }
    
    func setNotification(){
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = notificationBody
        content.sound = UNNotificationSound.default
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM d HH mm"
        let stringDate = dateFormatter.string(from: selectedDate)
        let dateArr = stringDate.split(separator: " ")
        let dateComp = DateComponents(year: Int(dateArr[0]),month: Int(dateArr[1]),day: Int(dateArr[2]),hour: Int(dateArr[3]),minute: Int(dateArr[4]))
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
        center.add(request) { error in
            print(error?.localizedDescription ?? "")
        }
        resetData()
    }
    
    func resetData(){
        doneRetrievingAllData = 0
        locationName = ""
        notificationTitle = ""
        notificationBody = ""
        alertPresent = false
    }
}

extension AlertsViewController: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let customAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        customAnnotation.image = UIImage(named: "mark")
        return customAnnotation
    }
}

extension AlertsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func setupNib(){
        let nib = UINib(nibName: AlertsConstants.cellClass, bundle: nil)
        alertsTable.register(nib, forCellReuseIdentifier: AlertsConstants.cellName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertViewModel.savedAlerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlertsConstants.cellName) as! AlertTableViewCell
        cell.setAlertData(savedAlert: alertViewModel.savedAlerts[indexPath.row])
        cell.backgroundColor = .clear
        cell.deleteThis = { [weak self] in
            self?.showOrHideAlert(hide: false)
            self?.itemTobeDeleteIndexPath = indexPath
        }
        return cell
    }
    
    func showOrHideAlert(hide: Bool){
        curtainView.isHidden = hide
        alertView.isHidden = hide
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        showOrHideAlert(hide: false)
        itemTobeDeleteIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension AlertsViewController{
    class AlertsConstants{
        static let cellName = "alertCell"
        static let cellClass = "AlertTableViewCell"
    }
}
