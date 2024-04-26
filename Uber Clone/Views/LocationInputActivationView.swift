import UIKit
protocol LocationInputIndicatorViewDelegate {
    func presentlocationInputIndicatorViewTap()
}

class LocationInputActivationView: UIView {
    
    //MARK: - Properties
    var delegate : LocationInputIndicatorViewDelegate?
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLable: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, left: leftAnchor, paddingLeft: 16)
        indicatorView.dimension(width: 6, height: 6)
        indicatorView.layer.cornerRadius = 6/2
        
        addSubview(placeholderLable)
        placeholderLable.centerY(inView: self)
        placeholderLable.anchor(left: indicatorView.rightAnchor, paddingLeft: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(locationInputIndicatorViewTap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func locationInputIndicatorViewTap() {
        delegate?.presentlocationInputIndicatorViewTap()
    }
    
}
