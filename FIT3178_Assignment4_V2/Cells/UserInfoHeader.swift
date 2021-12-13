//
//  UserInfoHeader.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/*
Reference:

YouTube Tutorial:
Title: How To Add A Settings Page To Your App | Swift 4 | Xcode 10
Author: AppStuff
Link:
https://www.youtube.com/watch?v=WqPoFzVrLj8&list=LLUCU7YsO_Fz4r_8crwV8pOA&index=38&t=1971s

*/


import UIKit

class UserInfoHeader: UIView {
    
    // MARK: - Properties
    
    let profileImageView: UIImageView = {
        let iv              = UIImageView()
        iv.contentMode      = .scaleAspectFill
        iv.clipsToBounds    = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "user")
        return iv
    }()

    let defaultLabel: UILabel = {
        let label       = UILabel()
        label.text      = "   DEFAULT ACCOUNT"
        label.font      = UIFont.systemFont(ofSize: 34)
        label.textColor = .brown
        label.translatesAutoresizingMaskIntoConstraints = false
        // label.frame = CGRect(x: 350, y: 150, width: 100, height: 20)
        return label
    }()
    
    
    // MARK: - Init
    
    init(frame: CGRect, user: User?, defaultHeader: Bool) {
        super.init(frame: frame)
        
        if !defaultHeader {
            let profileImageDimension: CGFloat = 60
            
            addSubview(profileImageView)
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageDimension).isActive = true
            profileImageView.layer.cornerRadius = profileImageDimension / 2
            
            let usernameLabel   = UILabel()
            usernameLabel.text  = user?.name
            usernameLabel.font  = UIFont.systemFont(ofSize: 16)
            usernameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            addSubview(usernameLabel)
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -10).isActive = true
            usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
            
            let emailLabel       = UILabel()
            emailLabel.text      = user?.email
            emailLabel.font      = UIFont.systemFont(ofSize: 14)
            emailLabel.textColor = .lightGray
            emailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(emailLabel)
            emailLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 10).isActive = true
            emailLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
            
        }else{
            addSubview(defaultLabel)
            defaultLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            defaultLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            defaultLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            defaultLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

