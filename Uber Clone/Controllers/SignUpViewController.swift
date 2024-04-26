import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    //MARK: - Properties
    private var titleLable: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 31)
        label.textColor = UIColor.init(white: 1, alpha: 0.8)
        return label
    }()
    
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
    
    private let accountTypeControl: UISegmentedControl = {
        let ac = UISegmentedControl(items: ["User","Driver"])
        ac.backgroundColor = .backgroundColor
        ac.tintColor = UIColor(white: 1, alpha: 0.87)
        ac.selectedSegmentIndex = 0
        return ac
    }()
    
    private let signupButton: UIButton = {
        let button = AuthButton()
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignupButton), for: .touchUpInside)
        return button
    }()
    
    private let goHomeButton: UIButton = {
        let btn = UIButton()
        
        var attributeTitle = NSMutableAttributedString(string: "Already Have An Account?.", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ])
        
        var goBackTitle = NSAttributedString(string: " Click Here:", attributes: [NSAttributedString.Key.foregroundColor : UIColor.link])
        attributeTitle.append(goBackTitle)
        
        btn.setAttributedTitle(attributeTitle, for: .normal)
        btn.addTarget(self, action: #selector(handleGoHomeButton), for: .touchUpInside)
        return btn
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: - Selectors
    @objc func handleGoHomeButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignupButton() {
        guard let email = emailTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let accountTypeIndex = accountTypeControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Fail to sign up new User \(error)")
                return
            }
            
            guard let uId = result?.user.uid else { return }
            
            let values = [ "email": email,
                           "fullname": username,
                           "accountType": accountTypeIndex] as [String : Any]
            
            Database.database().reference().child("users").child(uId).updateChildValues(values) { error, ref in
                if let error = error {
                    print("Fail to create user database \(error)")
                    return
                }

                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(HomeViewController(), animated: true)
                }
                print("Sign Up Success")
            }
        }
    }
    
    //MARK: - HelperFunctions
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    private func configureUI() {
        
        view.backgroundColor = UIColor.backgroundColor
        
        view.addSubview(titleLable)
        titleLable.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLable.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   usernameContainerView,
                                                   passwordContainerView,
                                                   accountTypeControlView,
                                                   signupButton
                                                  ])
        
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 15
        view.addSubview(stack)
        
        stack.anchor(top: titleLable.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 10,
                     paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(goHomeButton)
        goHomeButton.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 8, paddingRight: 8, paddingBottom: 10)
    }
}
