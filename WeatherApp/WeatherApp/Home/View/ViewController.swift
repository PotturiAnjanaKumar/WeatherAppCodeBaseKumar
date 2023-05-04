//
//  ViewController.swift
//  WeatherApp
//
//  Created by ANJANA KUMAR on 04/05/23.
//

import UIKit
import MapKit

protocol ListDelegate: AnyObject {
    func getSelectedCoordinate(coordinate: CLLocationCoordinate2D)
}

class ViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate {
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    lazy var viewmodel = HomeViewModel()
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        guard let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: Constants.listViewIdentifier) as? ListViewController else {
            return
        }
        locationSearchTable.deleagate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchBar.delegate = self
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = Constants.searchPlaces
        if let str = UserDefaults.standard.object(forKey: Constants.kLocationDefaults) as? String {
            resultSearchController?.searchBar.text = str
        }
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
}

extension ViewController: ListDelegate {
    func getSelectedCoordinate(coordinate: CLLocationCoordinate2D) {
        viewmodel.fetchWeatherData(coordinate: coordinate, completionHandler: {
            DispatchQueue.main.async() {
                self.updateUI()
            }
        })
    }
    
    private func updateUI() {
        cityName.text = viewmodel.weatherData?.name
        UserDefaults.standard.set(viewmodel.weatherData?.name, forKey: Constants.kLocationDefaults)
        if let temp = viewmodel.weatherData?.main.temp {
            let roundedDouble = Int(round(Double(temp)/28.6))
            let tempStr = "\(String(describing: (roundedDouble)))"
            tempLabel.text = NSString(format:"\(tempStr)%@ C" as NSString,  "\u{00B0}") as String
        }
        self.viewmodel.downloadImage(from: self.viewmodel.weatherData?.weather.first?.icon ?? "") { data in
            DispatchQueue.main.async() { [weak self] in
                self?.weatherImage.image = UIImage(data: data)
            }
        }
    }
}

extension ViewController : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            getSelectedCoordinate(coordinate: coordinate)
        }
    }
}
