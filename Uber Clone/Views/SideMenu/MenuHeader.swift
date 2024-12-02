//
//  MenuHeader.swift
//  Uber Clone
//
//  Created by S M H  on 08/10/2024.
//

import UIKit

class MenuHeader: UIView {

    //MARK: - Properties
    public var user: User
    
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        return image
    }()
    
    private lazy var fullnameLable: UILabel = {
        let label = UILabel()
        label.text = user.fullname
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = user.email
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor

        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,
                                left: leftAnchor,
                                paddingTop: 4,
                                paddingLeft: 12,
                                width: 64,
                                height: 64)
        profileImageView.layer.cornerRadius = 64/2

        let stack = UIStackView(arrangedSubviews: [fullnameLable, emailLabel])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 4

        addSubview(stack)
        stack.centerY(inView: profileImageView,
                      left: profileImageView.rightAnchor,
                      paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selector
    
    
    //MARK: - Helper Functions

}
