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
    func didCancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RiderActionViewConfiguration {
    case requestTrip
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case tripEnded
    
    init() {
        self = .requestTrip
    }
}

enum ButtonAction {
    case requestTrip
    case cancelTrip
    case getDirection
    case pickup
    case dropOff

    var description: String {
        switch self {
        case .requestTrip:
            return "COMFIRM USERX"
        case .cancelTrip:
            return "CANCEL TRIP"
        case .getDirection:
            return "GET DIRECTION"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
     
    init() {
        self = .requestTrip
    }
}

class RiderActionView: UIView {
    
    var selectedPlacemark: MKPlacemark? {
        didSet {
            titleLabel.text = selectedPlacemark?.name
            addresslabel.text = selectedPlacemark?.address
        }
    }
    
    var config: RiderActionViewConfiguration? {
        didSet {
            configureUI(withConfig: (config!))
        }
    }

    //MARK: - Properties
    var delegate: RiderActionViewDelegate?
    var buttonAction = ButtonAction()
    var user: User?
    
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
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(infoViewLabel)
        
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30)
        return label
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
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
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
        switch buttonAction {
        case .requestTrip:
            delegate?.uploadTrip(self)
        case .cancelTrip:
            delegate?.didCancelTrip()
        case .getDirection:
            print("DEBUG: Handle get direction btn")
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            delegate?.dropOffPassenger()
        }
    }
    
    func configureUI(withConfig config: RiderActionViewConfiguration) {
        
        switch config {
            
        case .requestTrip:
            break
            
        case .tripAccepted:
            
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                /// action view for driver side
                titleLabel.text = "Driver side"
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                /// action view for passenger side
                titleLabel.text = "Passenger side"
                buttonAction = .cancelTrip
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberXlabel.text = user.fullname
            
        case .driverArrived:
            
            guard let user = user else { return }
            
            if user.accountType == .driver {
                titleLabel.text = "Driver has arrived!"
                addresslabel.text = "Please meet driver at the pickup point!"
            }

        case .pickupPassenger:
            
            titleLabel.text = "Route to passenger"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
            
        case .tripInProgress:
            
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirection
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
        case .tripEnded:
            
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "Arrive at Destination"
        }
    }
}
