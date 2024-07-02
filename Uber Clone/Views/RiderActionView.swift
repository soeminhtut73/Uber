//
//  RiderActionView.swift
//  Uber Clone
//
//  Created by S M H  on 10/06/2024.
//

import UIKit
import MapKit

protocol RiderActionViewDelegate {
    func uploadTrip(_ view: RiderActionView)
}

class RiderActionView: UIView {
    
    var selectedPlacemark: MKPlacemark? {
        didSet {
            titleLabel.text = selectedPlacemark?.name
            addresslabel.text = selectedPlacemark?.address
        }
    }

    //MARK: - Properties
    var delegate: RiderActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Address Title"
        label.textAlignment = .center
        return label
    }()
    
    private let addresslabel: UILabel = {
        let label = UILabel()
        label.text = "BLK 678, Hougang Ave 8"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "X"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(label)
        
        label.centerX(inView: view)
        label.centerY(inView: view)
        return view
    }()
    
    private let uberXlabel: UILabel = {
        let label = UILabel()
        label.text = "UberX"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("CONFIRM UBERDX", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, addresslabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.centerX(inView: self)
        stackView.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stackView.bottomAnchor, paddingTop: 16)
        infoView.dimension(width: 60, height: 60)
        infoView.layer.cornerRadius = 60/2
        
        addSubview(uberXlabel)
        uberXlabel.centerX(inView: self)
        uberXlabel.anchor(top: infoView.bottomAnchor, paddingTop: 12)
        
        let separaterView = UIView()
        separaterView.backgroundColor = .black
        addSubview(separaterView)
        separaterView.anchor(top: uberXlabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, right: rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, paddingLeft: 12, paddingRight: 12, paddingBottom: 12, height: 50)
        actionButton.layer.cornerRadius = 10/2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selector
    @objc func actionButtonPressed() {
        delegate?.uploadTrip(self)
    }
    

}
