import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //MARK: - Properites
    
    private let titleLable: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 31)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
        
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: "ic_mail_outline_white_2x", textField: emailTextField)
        
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: "ic_lock_outline_white_2x", textField: passwordTextField)
        
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
        
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = AuthButton()
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't Have An Account? ", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.lightGray
        ])
        
        let signUpTitle = NSAttributedString(string: " SignUp.", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint
        ])
        
        attributedTitle.append(signUpTitle)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserLogin()
        configureNavigationBar()
//        signOut()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Selector
    
    @objc func handleShowSignUp() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        print("got login btn tap")
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Debug: Error login with \(error.localizedDescription)")
                return
            }
            print("Successfully Login User")
            self.navigationController?.pushViewController(HomeViewController(), animated: true)
            
        }
    }
    
    //MARK: - Helper Functions
    
    private func configureUI() {
        
        view.backgroundColor = UIColor.backgroundColor
        
        /// title lable layout
        view.addSubview(titleLable)
        titleLable.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLable.centerX(inView: view)
        
        /// arrange with stackview
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 15
        view.addSubview(stackView)
        stackView.anchor(top: titleLable.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 10,
                         paddingLeft: 16,
                         paddingRight: 16)
        
        /// signup button layout
        view.addSubview(signUpButton)
        signUpButton.centerX(inView: view)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,paddingBottom: 10)
        
        /*
        /// email container layout
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: titleLable.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        /// password container layout
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
         */
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    private func checkUserLogin() {
        if Auth.auth().currentUser == nil {
            print("User not login")
        } else {
            print("User login.")
            
            configureUI()
            navigationController?.pushViewController(HomeViewController(), animated: true)
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Signout success!")
        } catch {
            print("DEBUG: Fail to Sign out \(error.localizedDescription)")
        }
    }
}
