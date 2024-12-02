import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uID: String
    
    init(coordinate: CLLocationCoordinate2D, uID: String) {
        self.coordinate = coordinate
        self.uID = uID
    }
    
    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        print("update driver location get called")
        UIView.animate(withDuration: 0.5) {
            self.coordinate = coordinate
        }
    }
}
