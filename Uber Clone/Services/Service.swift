import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USER = DB_REF.child("users")
let REF_DRIVER_LOCATION = DB_REF.child("driver-locations")

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
                
                /* Driver uID got return */
                self.fetchUser(uID: uID) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
}
