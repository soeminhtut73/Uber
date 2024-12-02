//
//  UserInfoHeaderView.swift
//  Uber Clone
//
//  Created by S M H  on 01/11/2024.
//

import UIKit

class UserInfoHeaderView: UIView {
    
    //MARK: -  Properties
    
    public let user: User
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        return image
    }()
    
    
    private lazy var fullnameLable: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLable: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, left: leftAnchor, paddingLeft: 12)
        profileImageView.dimension(width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        let stackView = UIStackView(arrangedSubviews: [fullnameLable, emailLable])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, left: profileImageView.rightAnchor, paddingLeft: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
