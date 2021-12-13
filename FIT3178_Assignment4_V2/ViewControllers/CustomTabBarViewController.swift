//
//  CreateAlarmViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 Reference:
 
 Youtube Tutorial:
 Title: How to use Tab Bar in Xcode 9.0 (Swift 4.0)
 Author: Let Create An App
 Link: https://www.youtube.com/watch?v=YlkAq5nY1-4&list=LLUCU7YsO_Fz4r_8crwV8pOA&index=49&t=0s
 
 
 */

import UIKit

class CustomTabBarViewController: UITabBarController {
    
    var tableBarItem = UITabBarItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set color for UI Tab Bar
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        
        // Set up for summary part
        let selectedImage1         = UIImage(named: "round_poll_white_24pt")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1       = UIImage(named: "round_poll_black_24pt")?.withRenderingMode(.alwaysOriginal)
        tableBarItem               = self.tabBar.items![0]
        tableBarItem.image         = deSelectedImage1
        tableBarItem.selectedImage = selectedImage1
        
        // Set up for sleep part
        let selectedImage2         = UIImage(named: "round_alarm_white_24pt")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2       = UIImage(named: "round_alarm_black_24pt")?.withRenderingMode(.alwaysOriginal)
        tableBarItem               = self.tabBar.items![1]
        tableBarItem.image         = deSelectedImage2
        tableBarItem.selectedImage = selectedImage2
        
        // Set up for user part
        let selectedImage3         = UIImage(named: "round_face_white_24pt")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3       = UIImage(named: "round_face_black_24pt")?.withRenderingMode(.alwaysOriginal)
        tableBarItem               = self.tabBar.items![2]
        tableBarItem.image         = deSelectedImage3
        tableBarItem.selectedImage = selectedImage3
        
        self.selectedIndex = 1
    }
}


extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
