import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Properites
    private let titleLable: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
        
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        
        view.addSubview(titleLable)
        
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        titleLable.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
