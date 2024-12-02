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
    var homeLocation: String?
    var workLocation: String?
    
    init(uID: String, user: [String: Any]) {
        
        self.fullname = user["fullname"] as? String ?? "Undefined"
        self.email = user["email"] as? String ?? "Undefined"
        self.uID = uID
//        self.homeLocation = user["homeLocation"] as? String ?? ""
//        self.workLocation = user["workLocation"] as? String ?? ""
        
        if let workLocation = user["workLocation"] as? String {
            self.workLocation = workLocation
        }
        
        if let homeLocation = user["homeLocation"] as? String {
            self.homeLocation = homeLocation
        }
        
        if let index = user["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
