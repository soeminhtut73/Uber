import Foundation
import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uID: String
    
    init(uID: String, user: [String: Any]) {
        self.fullname = user["fullname"] as? String ?? "Undefined"
        self.email = user["email"] as? String ?? "Undefined"
        if let index = user["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
        
        self.uID = uID
    }
}
