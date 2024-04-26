import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private let locationInputActivationView = LocationInputActivationView()
    
    private let locationInputView = LocationInputView()
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        enableLocationServices()
    }
    
    //MARK: - Selector
    
    
    //MARK: - Helper Functions
    private func configureUI() {
        configureMapView()
        
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
        mapView.frame = view.bounds
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    private func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            print("DEBUG: Location input view got appear!")
        }

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
            self.locationInputView.alpha = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.locationInputActivationView.alpha = 1
            }
        }

    }
}
