import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    static let shared = LocationHandler()
    var locationManager: CLLocationManager?
    var location: CLLocation?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        location = CLLocation()
        locationManager?.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
}
