//
//  SettingsCell.swift
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

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    var sectionType: SectionType? {
        didSet {
            guard let sectionType   = sectionType else {return}
            textLabel?.text         = sectionType.description
            switchControl.isHidden  = !sectionType.containsSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl           = UISwitch()
        switchControl.isOn          = true
        switchControl.onTintColor   = UIColor(red: 79/255, green: 148/255, blue: 205/255, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("Turned on")
        } else {
            print("Turned off")
        }
    }
    
    
}
