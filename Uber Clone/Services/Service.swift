import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USER = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
let REF_TRIP = DB_REF.child("tips")

struct Service {
    public static var shared = Service()
    
    public func fetchUser(uID: String, completion: @escaping (User) -> Void) {
        REF_USER.child(uID).observeSingleEvent(of: .value) { snapshot  in
            guard let value = snapshot.value as? [String: Any] else { return }
            let user = User(uID: uID, user: value)
            completion(user)
        }
    }
    
    public func fetchDriver(location: CLLocation, completion: @escaping (User) -> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        
        REF_DRIVER_LOCATION.observe(.value) { snapshot in
            geoFire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uID, location in
                
                /*
                    Driver uID got return
                 */
                self.fetchUser(uID: uID) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    public func uploadTrip(_ pickupCoordinate: CLLocationCoordinate2D, _ destinationCoordinate: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pickupLocation = [pickupCoordinate.latitude, pickupCoordinate.longitude]
        let destinationLocation = [destinationCoordinate.latitude, destinationCoordinate.longitude]
        
        let values = ["pickupCoordinate" : pickupLocation,
                      "destinationCoordinate" : destinationLocation,
                      "state" : TripState.requested.rawValue] as [String : Any]
        
        REF_TRIP.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    public func observeTrip(completion: @escaping(Trip) -> Void) {
        REF_TRIP.observe(.childAdded) { snapshot,arg  in
            guard let value = snapshot.value as? [String: Any] else { return }
            let passengerUid = snapshot.key
            let trip = Trip(passengerUid: passengerUid, dictionary: value)
            completion(trip)
        }
    }
    
    public func acceptTrip(_ trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let driverUid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": driverUid, "state": TripState.accepted.rawValue] as [String: Any]
        
        REF_TRIP.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
}
