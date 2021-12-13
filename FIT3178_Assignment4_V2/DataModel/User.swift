//
//  User.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 10/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit


class User: NSObject {
    
    var id: String?
    var email: String = ""
    var name: String = ""
    var sleepData: [SleepData] = []
}
