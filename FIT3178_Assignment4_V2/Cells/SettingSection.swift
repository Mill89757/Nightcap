//
//  SettingSection.swift
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

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}


enum SettingSection: Int, CaseIterable, CustomStringConvertible {
    
    case Account
    case Alarm
    
    var description: String {
        switch self {
        case .Account:
            return "Account"
        case .Alarm:
            return "Alarm"
            
        }
    }
}


enum AccountOptions: Int, CaseIterable, SectionType {
    case logout
    case login
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .login:
            return "Log In"
        case .logout:
            return "Log Out"
        }
    }
}


enum AlarmOptions: Int, CaseIterable, SectionType {
    case notifications
    case changeAlarmSound
    
    var containsSwitch: Bool {
        switch self {
        case .notifications:
            return true
        
        case .changeAlarmSound:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .notifications:
            return "Notifications"
        case .changeAlarmSound:
            return "Change Alarm Sound"
        }
    }
}

