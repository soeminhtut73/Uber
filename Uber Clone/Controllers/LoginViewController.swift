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
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .mainBlueTint
        button.layer.cornerRadius = 5
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSMutableAttributedString(string: "Don't Have An Account? ", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.lightGray
        ])
        
        let signUpTitle = NSAttributedString(string: " SignUp.", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint
        ])
        
        title.append(signUpTitle)
        button.setAttributedTitle(title, for: .normal)
        
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        
        /// title lable layout
        view.addSubview(titleLable)
        titleLable.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLable.centerX(inView: view)
        
        /// arrange with stackview
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 24
        view.addSubview(stackView)
        stackView.anchor(top: titleLable.bottomAnchor,
                         left: view.leftAnchor,
                         right: view.rightAnchor,
                         paddingTop: 40,
                         paddingLeft: 16,
                         paddingRight: 16)
        
        /// signup button layout
        view.addSubview(signUpButton)
        signUpButton.centerX(inView: view)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,paddingBottom: 30)
        
        
        /*
        /// email container layout
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: titleLable.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        /// password container layout
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
         */
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
