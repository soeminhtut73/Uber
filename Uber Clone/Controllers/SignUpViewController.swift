import UIKit

class SignUpViewController: UIViewController {
    //MARK: - Properties
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: "ic_mail_outline_white_2x", textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let view = UIView().inputContainerView(image: "ic_person_outline_white_2x", textField: usernameTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: "ic_lock_outline_white_2x", textField: passwordTextField)
        view.anchor(height: 50)
        return view
    }()
    
    private lazy var accountTypeControlView: UIView = {
        let view = UIView().inputContainerView(image: "ic_account_box_white_2x", accountTypeControl: accountTypeControl)
        view.anchor(height: 80)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField().textField(withPlaceholder: "Username", isSecureTextEntry: false)
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
        return textField
    }()
    
    private let goHomeButton: UIButton = {
        let btn = UIButton()
        var attributeTitle = NSAttributedString(string: "Go back to login screen.", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ])
        
        
        btn.setAttributedTitle(<#T##NSAttributedString?#>, for: <#T##UIControl.State#>)
        return btn
    }()
    
    private let accountTypeControl: UISegmentedControl = {
        let ac = UISegmentedControl(items: ["User","Driver"])
        ac.backgroundColor = .backgroundColor
        ac.tintColor = UIColor(white: 1, alpha: 0.87)
        ac.selectedSegmentIndex = 0
        return ac
    }()
    
//    private let accountControlType
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   usernameContainerView,
                                                   passwordContainerView,
                                                   accountTypeControlView])
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        view.addSubview(stack)
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingLeft: 16,
                     paddingRight: 16)
    }
    
    //MARK: - Selectors
    
    //MARK: - HelperFunctions
}
