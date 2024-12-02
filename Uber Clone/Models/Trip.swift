import CoreLocation

enum TripState: Int {
    case requested // 0
    case accepted // 1
    case driverArrived // 2
    case inProgress // 3
    case arriveAtDestination // 4
    case completed // 5
    case denied // 6
}

struct Trip {
    var pickupCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var passengerUid: String!
    var driverUid: String?
    var state: TripState!
    
    init(passengerUid: String, dictionary: [String : Any]) {
        if let pickupCoordinate = dictionary["pickupCoordinate"] as? NSArray {
            guard let lat = pickupCoordinate[0] as? CLLocationDegrees else { return }
            guard let lon = pickupCoordinate[1] as? CLLocationDegrees else { return }
            self.pickupCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        if let destinationCoordinate = dictionary["destinationCoordinate"] as? NSArray {
            guard let lat = destinationCoordinate[0] as? CLLocationDegrees else { return }
            guard let lon = destinationCoordinate[1] as? CLLocationDegrees else { return }
            self.destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        
        self.passengerUid = passengerUid
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}

