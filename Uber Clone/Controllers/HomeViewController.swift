import UIKit
import MapKit
import CoreLocation
import Firebase

private let annotationIdentifier = "driverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private let locationInputActivationView = LocationInputActivationView()
    
    private let locationInputView = LocationInputView()
    
    private let locationInputViewHeight: CGFloat = 200
    
    private let tableView = UITableView()
    
    private var searchResult = [MKPlacemark]()
    
    private var actionButtonConfig = ActionButtonConfiguration()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
        fetchUserData()
        fetchDriver()
    }
    
    //MARK: - Selector
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: Show Menu button got pressed!")
        case . dismissActionView:
            /*
              - loop through annotation on MapView
              - find annotation on MapView where MKPointAnnotation
              - remove annotation
             */
            mapView.annotations.forEach { annotations in
                if let anno = annotations as? MKPointAnnotation {
                    mapView.removeAnnotation(anno)
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
            }
        }
    }
    
    //MARK: - API
    private func fetchUserData() {
        guard let uID = Auth.auth().currentUser?.uid else { return }
        
        Service.shared.fetchUser(uID: uID) { user in
            DispatchQueue.main.async {
                self.locationInputView.user = user
            }
        }
    }
    
    /* Update Driver Annotation
     -   fetch driver from firebase
     -   check fetch driver location with MapView location
     -   check both driver are same location. If same do not update. Otherwise update
     */
    private func fetchDriver() {
        guard let location = locationManager?.location else { return }
        
        Service.shared.fetchDriver(location: location) { driver in
            
            guard let coordinate = driver.location?.coordinate else { return }
            
            let annotation = DriverAnnotation(coordinate: coordinate, uID: driver.uID)
            
            var isDriverVisible: Bool {
                return self.mapView.annotations.contains { anno in
                    guard let driverAnno = anno as? DriverAnnotation else { return false }
                    if driverAnno.uID == driver.uID {
                        driverAnno.updateDriverLocation(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !isDriverVisible {
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        configureActionButton()
        configureLocationInputActivationView()
        configureTableView()
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.frame = view.bounds
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func configureActionButton() {
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
    }
    
    private func configureLocationInputActivationView() {
        view.addSubview(locationInputActivationView)
        locationInputActivationView.centerX(inView: view)
        locationInputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        locationInputActivationView.dimension(width: view.frame.width - 64, height: 50)
        locationInputActivationView.alpha = 0
        locationInputActivationView.delegate = self
        
        UIView.animate(withDuration: 1) {
            self.locationInputActivationView.alpha = 1
        }
    }
    
    private func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
            self.tableView.frame.origin.y = self.locationInputViewHeight
        }
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        tableView.rowHeight = 60
        
        let tableViewHeight = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: locationInputViewHeight + tableViewHeight , width: view.frame.width, height: tableViewHeight)
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButtonConfig = .showMenu
            self.actionButton.setImage(UIImage(named: FileNames.sideMenuButton), for: .normal)
        case .dismissActionView:
            self.actionButtonConfig = .dismissActionView
            self.actionButton.setImage(UIImage(named: FileNames.backArrowButton), for: .normal)
        }
    }
    
    private func dismissLocationInputView_V1(searchData: MKPlacemark? = nil, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.removeFromSuperview()
            self.tableView.frame.origin.y = self.view.frame.height
            
        } completion: { _ in
            guard let searchData = searchData else { return }
            let annotation = MKPointAnnotation()
            annotation.coordinate = searchData.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            completion!(true)
        }

    }
    
}

//MARK: - MKMapView Helper Functions
extension HomeViewController {
    /*
     -   Create MKLocalSearchRequest
     -   Implement request properties
     -   Initialize request
     */
    func searchBy(query: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard response != nil, error == nil else { return }
            
            guard let response = response else { return }
            
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            completion(results)
        }
        
        
    }
}

//MARK: - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}

//MARK: - Location Services
extension HomeViewController {
    private func enableLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager?.authorizationStatus {
                case .notDetermined:
                    self.locationManager?.requestWhenInUseAuthorization()
                case .restricted, .denied:
                    break
                case .authorizedAlways:
                    self.locationManager?.startUpdatingLocation()
                    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                case .authorizedWhenInUse:
                    self.locationManager?.requestAlwaysAuthorization()
                case .none:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}

//MARK: - LocationInputActivationViewDelegate
extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputActivationViewTap() {
        locationInputActivationView.alpha = 0
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate
extension HomeViewController: LocationInputViewDelegate {
    func executeQuery(query: String) {
        searchBy(query: query) { results in
            self.searchResult = results
            self.tableView.reloadData()
        }
    }
    
    ///  also dissmiss location input view
    func presentBackButtonGotTap() {
        self.dismissLocationInputView_V1()
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputActivationView.alpha = 1
        }
    }
}

//MARK: - Location Table View Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        if indexPath.section == 1 {
            cell.placemark = searchResult[indexPath.row]
        }
        return cell
    }
    
    /*
     -  create annotation
     -  add annotation coordinate
     -  mapView add annotation
     -  mapView selecte Annotation
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResult = searchResult[indexPath.row]
        dismissLocationInputView_V1(searchData: searchResult) { result in
            if result {
                self.configureActionButton(config: .dismissActionView)
            }
        }
    }
    
}
