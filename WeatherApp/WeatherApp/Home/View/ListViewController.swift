//
//  ListViewController.swift
//  WeatherApp
//
//  Created by ANJANA KUMAR on 04/05/23.
//

import UIKit
import MapKit
struct Constants {
    static var cellIdentifier = "cell"
    static var kLocationDefaults = "recentDestination"
    static var searchPlaces = "Search for places"
    static var listViewIdentifier = "ListViewController"
}
class ListViewController: UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    weak var deleagate: ListDelegate?
    var viewModel: HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? LocationDescriptionCell else {
            return UITableViewCell()
        }
        let selectedItem = matchingItems[indexPath.row]
        cell.updateCell(mapItem: selectedItem)
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        self.deleagate?.getSelectedCoordinate(coordinate: selectedItem.placemark.coordinate)
        dismiss(animated: true, completion: nil)
    }
}

extension ListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) { }
}
