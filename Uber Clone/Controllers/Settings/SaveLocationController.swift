//
//  SaveLocationController.swift
//  Uber Clone
//
//  Created by S M H  on 07/11/2024.
//

import UIKit
import MapKit
import CoreLocation

private let reuseIdentifier = "Cell"

protocol SaveLocationControllerDelegate {
    func updateSaveLocation(locationString: String, type: LocationType)
}

class SaveLocationController: UITableViewController {
    
    //MARK: - Properties
    
    private let searchBar = UISearchBar()
    
    var delegate: SaveLocationControllerDelegate?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResult = [MKLocalSearchCompletion]() {
        didSet {
             tableView.reloadData()
        }
    }
    
    private var location: CLLocation
    private var locationType: LocationType
    
    
    //MARK: - Lifecycle
    
    init(location: CLLocation, locationType: LocationType) {
        self.location = location
        self.locationType = locationType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    
    //MARK: - Helper Functions
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        
        tableView.addShadow()
    }
    
    func configureNavigationBar() {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationItem.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func configureSearchBar() {
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.placeholder = "Search..."
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
        
    }
    
}

//MARK: - Tableview Datasource

extension SaveLocationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = searchResult[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        var content = cell.defaultContentConfiguration()
        content.text = result.title
        content.secondaryText = result.subtitle
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let result = searchResult[indexPath.row]
        let title = result.title
        let subtitle = result.subtitle
        let locationString = title + " " + subtitle
        
        /// remove "Singapre" from selected location string
        let trimLocationString = locationString.replacingOccurrences(of: ", Singapore", with: "")
        delegate?.updateSaveLocation(locationString: trimLocationString, type: locationType)
        
    }
    
}


extension SaveLocationController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
}

extension SaveLocationController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResult = completer.results
    }
    
}

/*
 
 // setup completer
 setup completer and for storing result
 configure searchCompleter for custom region
 
 // action for completer
 searchBar textDidChange try to query in searchComplter.queryFragment
 listen for searchResult after textDidChange in MKLocalSearchCompleterDelegate
 
 */
