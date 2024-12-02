//
//  LocationTableViewCell.swift
//  Uber Clone
//
//  Created by MAC on 27/04/2024.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    static let identifier = "LocationTableViewCell"
    
    // Placemark for search results
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    var locationType: LocationType? {
        didSet {
            titleLabel.text = locationType?.description
            addressLabel.text = locationType?.subTitle
        }
    }
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    public let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerY(inView: self, left: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors

}
