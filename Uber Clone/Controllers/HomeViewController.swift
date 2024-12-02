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

enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeViewControllerDelegate {
    func handleMenuToggle()
}

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let locationInputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let locationInputViewHeight: CGFloat = 200
    private let tableView = UITableView()
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    private let riderActionView = RiderActionView()
    private let riderActionViewHeight: CGFloat = 300
    private var searchResult = [MKPlacemark]()
    private var saveLocations = [MKPlacemark]()
    
    var delegate: HomeViewControllerDelegate?
    
    var user: User? {
        didSet {
            self.locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDriver()
                configureLocationInputActivationView()
                observeCurrentTrip()
                configureSaveUserLocation()
            } else {
                fetchTrip()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            
            guard let user = user else { return }
            
            if user.accountType == .driver {
                /*
                    PickupController show up
                 */
                guard let trip = trip else { return }
                let controller = PickupController(trip: trip)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            } else {
                /*
                    Handle loading screen configuration
                 */
                
            }
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: FileNames.sideMenuButton)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
        configureRiderActionView()
    }
    
    //MARK: - Selector
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle()
        case . dismissActionView:
            removeAnnotationAndOverlays()
            
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
            }
            animateRiderActionView(shouldShow: false)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    //MARK: - Passenger API
    /* Update Driver Annotation
     -   fetch driver from firebase
     -   check fetch driver location with MapView location
     -   check both driver are same location. If same do not update. Otherwise update
     */
    private func fetchDriver() {
        guard let location = locationManager?.location else { return }
        
        PassengerService.shared.fetchDriver(location: location) { driver in
            
            guard let coordinate = driver.location?.coordinate else { return }
            
            // change to driver annotation
            let annotation = DriverAnnotation(coordinate: coordinate, uID: driver.uID)
            
            var isDriverVisible: Bool {
                return self.mapView.annotations.contains { anno in
                    guard let driverAnno = anno as? DriverAnnotation else { return false }
                    if driverAnno.uID == driver.uID {
                        driverAnno.updateDriverLocation(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uID)
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
    
    // listen current trip for both driver and passenger
    private func observeCurrentTrip() {
        
        // For passenger side
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let driverUid = trip.driverUid else { return }
            guard let state = trip.state else { return }
            
            // Switch for trip state
            switch state {
            case .requested:
                print("DEBUG: Trip in requested")
                
            case .accepted:
                print("DEBUG: Trip accepted")
                self.shouldPresentLoadingView(false)
                self.removeAnnotationAndOverlays()
                self.zoomForActiveTrip(withDriverUid: driverUid)
                
                // fetch user data with driverUid
                Service.shared.fetchUser(uID: driverUid) { driver in
                    // passing through DRIVER DATA for user ride action view
                    self.animateRiderActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.riderActionView.config = .driverArrived
                
            case .inProgress:
                self.riderActionView.config = .tripInProgress
                
            case .arriveAtDestination:
                self.riderActionView.config = .tripEnded
            
            case .completed:
                PassengerService.shared.deleteTrip { error, ref in
                    guard error == nil else { return }
                    
                    self.animateRiderActionView(shouldShow: false)
                    self.centerOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.locationInputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Trip Completed!", withMessage: "We hope you enjoy the trip!")
                }
            }
        }
    }
    
    func startTrip() {
        guard let trip = trip else { return }
        
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { err, ref in
            guard err == nil else { return }
            
            self.riderActionView.config = .tripInProgress
            self.removeAnnotationAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinate)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinate)
            let mapItem = MKMapItem(placemark: placemark)
            self.generatePolyline(to: mapItem)
            
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            self.setCustomRegion(withType: .destination, coordinate: trip.destinationCoordinate)
        }
    }
    
    //MARK: - Driver API
    
    private func fetchTrip() {
        DriverService.shared.observeTrip { trip in
            self.trip = trip
        }
    }
    
    private func observeCancelTrip(with trip: Trip) {
        DriverService.shared.observeCancelTrip(trip: trip) {
            self.removeAnnotationAndOverlays()
            self.presentAlertController(withTitle: "Oops!", withMessage: "Passenger has cancel the trip!")
            self.animateRiderActionView(shouldShow: false)
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    //MARK: - Shared API
//    private func fetchUserData() {
//        guard let uID = Auth.auth().currentUser?.uid else { return }
//        
//        Service.shared.fetchUser(uID: uID) { user in
//            DispatchQueue.main.async {
//                self.user = user
//            }
//        }
//    }
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        configureActionButton()
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
        
        UIView.animate(withDuration: 0.2) {
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
            
            self.mapView.addAnnotationAndSelect(forCoordinate: searchData.coordinate)
            
            completion!(true)
        }

    }
    
    private func configureRiderActionView() {
        view.addSubview(riderActionView)
        riderActionView.delegate = self
        riderActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: riderActionViewHeight)
    }
    
    private func animateRiderActionView(shouldShow: Bool, selectedPlacemark: MKPlacemark? = nil, config: RiderActionViewConfiguration? = nil, user: User? = nil) {
       
        let yOrigin = shouldShow ? view.frame.height - riderActionViewHeight : view.frame.height
        
        UIView.animate(withDuration: 0.5) {
            self.riderActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            
            if let selectedPlacemark = selectedPlacemark {
                riderActionView.selectedPlacemark = selectedPlacemark
            }
            
            if let user = user {
                riderActionView.user = user
            }
            
            if let config = config {
                riderActionView.configureUI(withConfig: config)
            }
        }
    }
    
    
    /*
     -  get homeLocation and workLocation from user object and get geoCodeAddressString
     -  CLGeocoder -> convert MKPlacemarks -> append on saveLocations
     */
    
    //  -   fetch save userLocation
    func configureSaveUserLocation() {
        guard let user = user else { return }
        saveLocations.removeAll()
        
        if let homeLocation = user.homeLocation {
            geoAddressString(from: homeLocation)
        }
        
        if let workLocation = user.workLocation {
            geoAddressString(from: workLocation)
        }
    }
    
    // convert locationString to geoAddressString
    func geoAddressString(from locationString: String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) { placemarks, error in
            guard let placemarks = placemarks?.first else { return }
            
            let mkPlacemark = MKPlacemark(placemark: placemarks)
            self.saveLocations.append(mkPlacemark)
            
            self.tableView.reloadData()
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
    private func searchBy(query: String, completion: @escaping([MKPlacemark]) -> Void) {
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
    
    /*
     -  Create MKDirection Request
     -  Configure MKDirection Request
     -  Generate request properties
     -  Initiate MKDirection
     -  Direction calculate
     */
    private func generatePolyline(to destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            guard let response = response, error == nil else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    /*
      - loop through annotation on MapView
      - find annotation on MapView where MKPointAnnotation
      - remove annotation
     */
    private func removeAnnotationAndOverlays() {
        mapView.annotations.forEach { anno in
            if let anno = anno as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    //set location to center for current location
    func centerOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    /*
        -   create circular region for location 
        -   initiate locationManager to start monitoring for specific region
     */
    func setCustomRegion(withType type: AnnotationType, coordinate: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinate, radius: 10, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
    }
    
    func zoomForActiveTrip(withDriverUid uID: String ) {
        // Filter the driver and current user annotation
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { annotation in
            if let driverAnno = annotation as? DriverAnnotation {
                // check trip.driverUid and driverAnno.uID
                if driverAnno.uID == uID {
                    annotations.append(driverAnno)
                }
            }
            
            // get current passenger uID
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
//                print("DEBUG: Annotation in trip accepted condition \(annotations.count)")
        self.mapView.zoomToFit(annotations: annotations)
    }
}

//MARK: - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    
    ///     Perform action on user's location has changed
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        guard user.accountType == .driver else { return }
        guard let location = userLocation.location else { return }
        DriverService.shared.dynamicUpdateDriverLocation(location: location)
    }
    
    ///     Add custom driver's annotation on mapview
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    ///     Add Delegate renderer for polyline to add on mapview
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        if let route = route {
            let polyline = route.polyline
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

//MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    
    /// start monioring for circular radius
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitor location manager delegate \(region.identifier)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitor location manager delegate \(region.identifier)")
        }
    }
    
    /// notify to driver when come near to pickup location ## Driver side
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("DEBUG: Did enter in pickup region")
        
        guard let trip = trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { err, ref in
                self.riderActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .arriveAtDestination) { err, ref in
                self.riderActionView.config = .tripEnded
            }
        }
    }
    
    private func enableLocationServices() {
        /// location manager delegate
        locationManager?.delegate = self
        
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
        if section == 0 {
            return "Save Locations"
        } else {
            return "Search Results"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? saveLocations.count : searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        
        if indexPath.section == 0 {
            print("Debug: saveLocation # \(saveLocations[indexPath.row])")
            cell.placemark = saveLocations[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell.placemark = searchResult[indexPath.row]
        }
        return cell
    }
    
    /*
     -  create annotation
     -  add annotation coordinate
     -  mapView add annotation
     -  mapView select Annotation
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedPlacemark =  indexPath.section == 0 ? saveLocations[indexPath.row] : searchResult[indexPath.row]
        print("Debug: selectedPlacemark # \(selectedPlacemark)")
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        self.generatePolyline(to: destination)
        print(destination.placemark.coordinate)
        
        dismissLocationInputView_V1(searchData: selectedPlacemark) { result in
            if result {
                self.configureActionButton(config: .dismissActionView)
            }
            
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            
            self.mapView.zoomToFit(annotations: annotations)
            self.mapView.showAnnotations(annotations, animated: true)
            self.animateRiderActionView(shouldShow: true, selectedPlacemark: selectedPlacemark)
            self.animateRiderActionView(shouldShow: true, selectedPlacemark: selectedPlacemark)
        }
    }
}

//MARK: - RiderActionViewDelegate
extension HomeViewController: RiderActionViewDelegate {
    func uploadTrip(_ view: RiderActionView) {
        
        guard let pickupCoordinate = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinate = view.selectedPlacemark?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a rider...")
        
        PassengerService.shared.uploadTrip(pickupCoordinate, destinationCoordinate) { err, ref in
            if let error = err {
                print("DEBUG: Error uploading trip \(error)")
                return
            }
            print("DEBUG: Uploading trip successful!")
        }
        
        UIView.animate(withDuration: 0.3) {
            self.riderActionView.frame.origin.y = self.view.frame.height
        }
    }
    
    func didCancelTrip() {
        PassengerService.shared.deleteTrip { err, ref in
            guard err == nil else { return }
            
            self.animateRiderActionView(shouldShow: false)
            self.removeAnnotationAndOverlays()
            self.centerOnUserLocation()
            self.configureActionButton(config: .showMenu)
            print("DEBUG: Trip has been cancel by passenger")
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = trip else { return }
        
        DriverService.shared.updateTripState(trip: trip, state: .completed) { error, ref in
            //take action after trip complete
            self.removeAnnotationAndOverlays()
            self.centerOnUserLocation()
            self.animateRiderActionView(shouldShow: false)
        }
    }
}

//MARK: - PickupControllerDelegate
extension HomeViewController: PickupControllerDelegate {
    func didAcceptTrip(trip: Trip) {
        self.trip = trip
        
        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinate)
        
        setCustomRegion(withType: .pickup,coordinate: trip.pickupCoordinate)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(to: mapItem)
        self.mapView.zoomToFit(annotations: mapView.annotations)
        
        observeCancelTrip(with: trip )
        
        self.dismiss(animated: true) {
            
            ///     passing through PASSENGER DATA to show for driver ride action view
            Service.shared.fetchUser(uID: trip.passengerUid) { passenger in
                self.animateRiderActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
            
        }
    }
}

/// get annotation for MKUserLocation and MKPointAnnotation
/*
 self.mapView.annotations.forEach { annotation in
     if let anno = annotation as? MKUserLocation {
         annotations.append(anno)
     }
     
     if let anno = annotation as? MKPointAnnotation {
         annotations.append(anno)
     }
 }
 
 self.mapView.showAnnotations(annotations, animated: true)
 */
