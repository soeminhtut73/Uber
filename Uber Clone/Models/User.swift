import Foundation
import CoreLocation

struct User {
    
    let fullname: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    let uID: String
    
    init(uID: String, user: [String: Any]) {
        self.fullname = user["fullname"] as? String ?? "Undefined"
        self.email = user["email"] as? String ?? "Undefined"
        self.accountType = user["accountType"] as? Int ?? 0
        self.uID = uID
    }
}
