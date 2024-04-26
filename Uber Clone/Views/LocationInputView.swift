import UIKit
protocol LocationInputViewDelegate {
    func presentBackButtonGotTap()
}

class LocationInputView: UIView {
    
    //MARK: - Properties
    var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_arrow_back_black_36dp-1")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backButtonGotTap), for: .touchUpInside)
        return button 
    }()
    
    //MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 30, height: 30)
        addShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func backButtonGotTap() {
        self.delegate?.presentBackButtonGotTap()
    }
    
}


