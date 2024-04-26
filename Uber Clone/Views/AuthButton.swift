import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.mainBlueTint
        layer.cornerRadius = 5
        setTitleColor(UIColor.label, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
