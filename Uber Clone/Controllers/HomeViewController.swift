import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private let locationInputIndicatorView = LocationInputIndicatorView()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
    }
    
    //MARK: - Selector
    
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureLocation()
        
        view.addSubview(locationInputIndicatorView)
        locationInputIndicatorView.centerX(inView: view)
        locationInputIndicatorView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        locationInputIndicatorView.dimension(width: view.frame.width - 64, height: 50)
    }
    
    private func configureLocation() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }

}

//MARK: - Location Services
extension HomeViewController: CLLocationManagerDelegate {
    
    private func enableLocationServices() {
        locationManager.delegate = self
        
        DispatchQueue.global().async {
            
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                case .restricted, .denied:
                    break
                case .authorizedAlways:
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                case .authorizedWhenInUse:
                    self.locationManager.requestAlwaysAuthorization()
                @unknown default:
                    break
                }
            }
        }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
