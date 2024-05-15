import UIKit
import MapKit
import CoreLocation
import Firebase

private let annotationIdentifier = "driverAnnotation"

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    
    private let locationManager = LocationHandler.shared.locationManager
    
    private let locationInputActivationView = LocationInputActivationView()
    
    private let locationInputView = LocationInputView()
    
    private let locationInputViewHeight: CGFloat = 200
    
    private let tableView = UITableView()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
        fetchUserData()
        fetchDriver()
    }
    
    //MARK: - Selector
    
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
        configureTableView()
        
        view.addSubview(locationInputActivationView)
        locationInputActivationView.centerX(inView: view)
        locationInputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        locationInputActivationView.dimension(width: view.frame.width - 64, height: 50)
        locationInputActivationView.alpha = 0
        locationInputActivationView.delegate = self
        
        UIView.animate(withDuration: 1) {
            self.locationInputActivationView.alpha = 1
        }
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.frame = view.bounds
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
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

extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputActivationViewTap() {
        locationInputActivationView.alpha = 0
        configureLocationInputView()
    }
}

extension HomeViewController: LocationInputViewDelegate {
    func presentBackButtonGotTap() {
        UIView.animate(withDuration: 0.3) {
//            self.locationInputView.alpha = 0
            self.locationInputView.removeFromSuperview()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.tableView.frame.origin.y = self.view.frame.height
            }
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
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath)
        
        return cell
    }
    
    
}
