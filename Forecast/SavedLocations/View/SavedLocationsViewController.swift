//
//  SavedLocationsViewController.swift
//  Forecast
//
//  Created by Ahmed on 22/07/2023.
//

import UIKit
import Lottie
import MapKit
import RealmSwift

class SavedLocationsViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var pageHeader: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var mapItself: MKMapView!
    @IBOutlet weak var curtainView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var savedLocationsTable: UITableView!
    @IBOutlet weak var noSavedLocationsView: UIView!
    @IBOutlet weak var bookmarkAnimation: LottieAnimationView!
    let annotation = MKPointAnnotation()
    var savedLocationsViewModel = SavedLocationsViewModel(localSource: ConcreteLocalSource())
    let networkIndicator = UIActivityIndicatorView()
    var selectedLocation: CLLocationCoordinate2D!
    let setup = Setup()
    var itemTobeDeleteIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 20)
        mapItself.delegate = self
        setupTabelNib()
        setupNetworkIndicator()
        handleSuccessfulyReturningSavedLocations()
    }
    
    func handleSuccessfulyReturningSavedLocations(){
        checkWhichViewToHideOrShow()
        savedLocationsTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageHeader.adjustHeaderFontSizeBasedOnLanguage()
        savedLocationsViewModel.getSavedLocations()
        showOrHideMap(hide: true)
        showOrHideAlert(hide: true)
        bookmarkAnimation.play()
        mapContainerView.giveShadowAndRadius(shadowRadius: 5, cornerRadius: 30)
        mapItself.layer.cornerRadius = 30
        setup.setupViewControllerBackgroundGradient(me: self)
        checkWhichViewToHideOrShow()
    }
    
    func setupNetworkIndicator(){
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
    }
    
    func checkWhichViewToHideOrShow(){
        if savedLocationsViewModel.savedLocations.isEmpty {
            savedLocationsTable.isHidden = true
            noSavedLocationsView.isHidden = false
        }else{
            savedLocationsTable.isHidden = false
            noSavedLocationsView.isHidden = true
            savedLocationsTable.reloadData()
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let settings = self.storyboard?.instantiateViewController(identifier: "settings") as! SettingsViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    func showOrHideMap(hide: Bool){
        curtainView.isHidden = hide
        mapContainerView.isHidden = hide
    }
    
    func showOrHideAlert(hide: Bool){
        curtainView.isHidden = hide
        alertView.isHidden = hide
    }
    
    @IBAction func addAnotherLocation(_ sender: Any) {
        showOrHideMap(hide: false)
        doneButton.isHidden = true
    }
    
    @IBAction func hideMap(_ sender: Any) {
        showOrHideMap(hide: true)
        alertView.isHidden = true
    }

    @IBAction func exitMap(_ sender: Any) {
        showOrHideMap(hide: true)
    }
    
    @IBAction func selectPointOnMap(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapItself)
        let location = mapItself.convert(point , toCoordinateFrom: mapItself)
        annotation.coordinate = location
        mapItself.removeAnnotations(mapItself.annotations)
        mapItself.addAnnotation(annotation)
        doneButton.isHidden = false
        doneButton.isEnabled = true
        selectedLocation = location
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let customAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        customAnnotation.image = UIImage(named: "mark")
        return customAnnotation
    }
    
    @IBAction func addLocationToSaved(_ sender: Any) {
        networkIndicator.startAnimating()
        doneButton.isEnabled = false
        CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude) .fetchCityAndCountry {[weak self] city, country, error in
            let addedLocation = SavedLocation()
            addedLocation.cityName = city ?? ""
            addedLocation.countryName = country ?? ""
            addedLocation.lat = String(self?.selectedLocation.latitude ?? 30.0444)
            addedLocation.lon = String(self?.selectedLocation.longitude ?? 30.2346)
            if (self?.savedLocationsViewModel.checkIfLocationIsNew(locationInQuestion: addedLocation)) ?? false {
                self?.savedLocationsViewModel.savedLocations.append(addedLocation)
                self?.savedLocationsViewModel.addNewLocation(locationToAdd: addedLocation)
            }
            self?.showOrHideMap(hide: true)
            self?.doneButton.isHidden = true
            self?.checkWhichViewToHideOrShow()
            self?.savedLocationsTable.reloadData()
            self?.mapItself.removeAnnotations((self?.mapItself.annotations)!)
            self?.networkIndicator.stopAnimating()
        }
    }
    
    @IBAction func confirmDelete(_ sender: Any) {
        savedLocationsViewModel.deleteLocation(locationToDelete: savedLocationsViewModel.savedLocations[itemTobeDeleteIndexPath.row])
        savedLocationsViewModel.savedLocations.remove(at: itemTobeDeleteIndexPath.row)
        savedLocationsTable.deleteRows(at: [itemTobeDeleteIndexPath], with: .left)
        checkWhichViewToHideOrShow()
        showOrHideAlert(hide: true)
    }
    
    @IBAction func cancelDelete(_ sender: Any) {
        showOrHideAlert(hide: true)
    }
}

extension SavedLocationsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func setupTabelNib(){
        let cellNib = UINib(nibName: "SavedLocationTableViewCell", bundle: nil)
        savedLocationsTable.register(cellNib, forCellReuseIdentifier: "savedLocation")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLocationsViewModel.savedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedLocation") as! SavedLocationTableViewCell
        cell.setLocationData(savedLoctaion: savedLocationsViewModel.savedLocations[indexPath.row])
        cell.backgroundColor = UIColor.clear
        cell.deleteThis = { [weak self] in
            self?.showOrHideAlert(hide: false)
            self?.itemTobeDeleteIndexPath = indexPath
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firstNavController = self.tabBarController?.viewControllers?[1] as! UINavigationController
        let viewController = firstNavController.viewControllers.first as! ViewController
        viewController.lat = savedLocationsViewModel.savedLocations[indexPath.row].lat
        viewController.lon = savedLocationsViewModel.savedLocations[indexPath.row].lon
        viewController.fromSaved = true
        self.tabBarController?.selectedIndex = 1
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        showOrHideAlert(hide: false)
        itemTobeDeleteIndexPath = indexPath
    }
}
