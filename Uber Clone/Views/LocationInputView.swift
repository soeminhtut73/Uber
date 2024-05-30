import UIKit

protocol LocationInputViewDelegate {
    func presentBackButtonGotTap()
    func executeQuery(query: String)
}

class LocationInputView: UIView {
    
    //MARK: - Properties
    var delegate: LocationInputViewDelegate?
    
    public var user: User? {
        didSet {
            titleLabel.text = user?.fullname
        }
    }
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_arrow_back_black_36dp-1")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backButtonGotTap), for: .touchUpInside)
        return button 
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let startLocationInputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = .systemGroupedBackground
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        tf.isEnabled = false
        return tf
    }()
    
    private lazy var destinationLocationInputTextField: UITextField = {
        let tf = UITextField()
        
        tf.placeholder = "Select destination"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        tf.delegate = self
        return tf
    }()
    
    //MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 30, height: 30)
        addShadow()
        
        addSubview(titleLabel)
        titleLabel.centerX(inView: self)
        titleLabel.centerY(inView: backButton)
        
        addSubview(startLocationInputTextField)
        startLocationInputTextField.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(destinationLocationInputTextField)
        destinationLocationInputTextField.anchor(top: startLocationInputTextField.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 40, paddingRight: 40, height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startLocationInputTextField, left: leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.dimension(width: 6, height: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(destinationLocationIndicatorView)
        destinationLocationIndicatorView.centerY(inView: destinationLocationInputTextField, left: leftAnchor, paddingLeft: 20)
        destinationLocationIndicatorView.dimension(width: 6, height: 6)
        destinationLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(linkingLocationIndicatorView)
        linkingLocationIndicatorView.centerX(inView: startLocationIndicatorView)
        linkingLocationIndicatorView.anchor(top: startLocationIndicatorView.bottomAnchor, bottom: destinationLocationIndicatorView.topAnchor, paddingTop: 5, paddingBottom: 5, width: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func backButtonGotTap() {
        self.delegate?.presentBackButtonGotTap()
    }
    
}

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeQuery(query: query)
        return true
    }
}


