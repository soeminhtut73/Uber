import Firebase
import CoreLocation
import GeoFire

//MARK: - Database Ref
let DB_REF = Database.database().reference()
let REF_USER = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")
let REF_TRIP = DB_REF.child("trips")

//MARK: - Driver Service
struct DriverService {
    static let shared = DriverService()
    
    public func observeTrip(completion: @escaping(Trip) -> Void) {
        REF_TRIP.observe(.childAdded) { snapshot,arg  in
            guard let value = snapshot.value as? [String: Any] else { return }
            let passengerUid = snapshot.key
            let trip = Trip(passengerUid: passengerUid, dictionary: value)
            completion(trip)
        }
    }
    
    public func updateTripState(trip: Trip, state: TripState, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIP.child(trip.passengerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if trip.state == .completed {
            REF_TRIP.child(trip.passengerUid).removeAllObservers()
        }
    }
    
    public func dynamicUpdateDriverLocation(location: CLLocation) {
        guard let uID = Auth.auth().currentUser?.uid else { return }
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        geoFire.setLocation(location, forKey: uID)
    }
    
    public func acceptTrip(_ trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let driverUid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUid": driverUid, "state": TripState.accepted.rawValue] as [String: Any]
        
        REF_TRIP.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    public func observeCancelTrip(trip: Trip, completion: @escaping() -> Void) {
        REF_TRIP.child(trip.passengerUid).observeSingleEvent(of: .childRemoved, with: { _ in
            completion()
        })
    }
}

//MARK: - Passenger Service
struct PassengerService {
    static let shared = PassengerService()
    
    public func fetchDriver(location: CLLocation, completion: @escaping (User) -> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATION)
        
        REF_DRIVER_LOCATION.observe(.value) { snapshot in
            geoFire.query(at: location, withRadius: 50).observe(.keyEntered, with: { uID, location in
                
                /*
                    Driver uID got return
                 */
                Service.shared.fetchUser(uID: uID) { user in
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
    
    public func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
            
        REF_TRIP.child(userID).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let trip = Trip(passengerUid: userID, dictionary: dictionary)
            completion(trip)
        }
    }
    
    public func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIP.child(userID).removeValue(completionBlock: completion)
    }
    
    public func saveLocation(locationString: String, locationType: LocationType, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let key: String = locationType == .home ? "homeLocation" : "workLocation"
        
        REF_USER.child(userID).child(key).setValue(locationString, withCompletionBlock: completion)
    }
}

//MARK: - Shared API
struct Service {
    public static var shared = Service()
    
    public func fetchUser(uID: String, completion: @escaping (User) -> Void) {
        REF_USER.child(uID).observeSingleEvent(of: .value) { snapshot  in
            guard let value = snapshot.value as? [String: Any] else { return }
            let user = User(uID: uID, user: value)
            completion(user)
        }
    }
}
