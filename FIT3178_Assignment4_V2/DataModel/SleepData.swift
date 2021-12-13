//
//  Sleep.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 10/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

enum CodingKeys: String, CodingKey {
    case id
    case starttime
    case endtime
    case durationInSec
}

class SleepData: NSObject, Codable {
    
    var id: String?
    var durationInSec = 0
}
