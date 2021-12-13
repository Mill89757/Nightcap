//
//  DatabaseProtocol.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 4/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case application
    case sleep
    case user
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onSleepChange(change: DatabaseChange, sleepData: [SleepData])
    func onUserChange(change: DatabaseChange, newData: User?)
}

protocol DatabaseProtocol: AnyObject {
    var currentUser: User? { get  }
    
    func cleanup()
    func addSleepData(duration: Int) -> SleepData
    func addUser(name: String, email: String) -> User
    
    func addSleepDataToUser(sleepData: SleepData, user: User) -> Bool
    
    func deleteSleepData(sleepData: SleepData)
    
    // Get that user and update databse current user
    func fetchSpecificUser(email: String) -> User

    func deleteUser(user: User)
    func removeSleepDataFromUser(sleepData: SleepData, user: User)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
