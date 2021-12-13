//
//  FirebaseController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 10/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class FirebaseController: NSObject, DatabaseProtocol {

    var currentUser: User?
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var userRef: CollectionReference?
    var sleepDataRef: CollectionReference?
    
    
    var testFlag = false
    
    var sleepDataList: [SleepData] = []
    
    
    override init() {
        // To use Firebase in our application we first must run the
        // FirebaseApp configure method
        FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database       = Firestore.firestore()
        
       
        super.init()
        print("Hello Firebase controller")
        
    
        self.setUpSleepDataListener()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be
        // any time later
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
        }
    }
    
    
    func setUpSleepDataListener() {
        
        sleepDataRef = database.collection("sleepData")
        sleepDataRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            self.parseSleepDataSnapshot(snapshot: querySnapshot)
            self.setUpSpecificUserListener(email: "Default")
        }
        
    }
    
    
    func setUpAllUserListener() {
        userRef = database.collection("user")
        userRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot,
                let userSnapshot = querySnapshot.documents.first else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
            }
            
            self.parseUserSnapshot(snapshot: userSnapshot)
        }
        
    }
    
    
    func setUpSpecificUserListener(email: String){
        
        userRef = database.collection("user")
        
        
        userRef?.whereField("email", isEqualTo: email).addSnapshotListener{
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot,
                let userSnapshot = querySnapshot.documents.first else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
            }
            
            
            self.parseUserSnapshot(snapshot: userSnapshot)
            
            // For test
//            if self.testFlag == false {
//                self.addDummyForDefaultUser()
//                self.testFlag = true
//            }
        
        }
        
    }
    
    
    func fetchSpecificUser(email: String) -> User {
        // this email must exist in data base
        userRef = database.collection("user")
        
        userRef?.whereField("email", isEqualTo: email).getDocuments(){
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot,
                let userSnapshot = querySnapshot.documents.first else {
                    print("Error fetching specific user info: \(String(describing: error))")
                    return
            }
            self.currentUser?.name = userSnapshot.data()["name"] as! String
            self.currentUser?.id   = userSnapshot.documentID
            self.currentUser?.email = userSnapshot.data()["email"] as! String
            self.currentUser?.sleepData = []
            if let sleepDataReferences = userSnapshot.data()["sleepData"] as? [DocumentReference] {
                // If the document has a "heroes" field, add heroes.
                for reference in sleepDataReferences {
                    print(reference.documentID)
                    if let sleepData = self.getSleepDataByID(reference.documentID) {
                        self.currentUser?.sleepData.append(sleepData)
                    }
                }
                
            }
//            self.currentUser?.sleepData = userSnapshot.data()["sleepData"] as! [SleepData]
        }
        return currentUser!
    }
    
    
    func parseSleepDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let sleepDataID = change.document.documentID
            print("Sleep Data ID: ", sleepDataID)

            var parsedSleepData: SleepData?

            do {
                parsedSleepData = try change.document.data(as: SleepData.self)
            } catch {
                print("Unable to decode sleep data. Is the sleep data malformed?")
                return
            }

            guard let sleepData = parsedSleepData else {
                print("Document doesn't exist")
                return;
            }

            sleepData.id = sleepDataID
            if change.type == .added {
                sleepDataList.append(sleepData)
            }
            else if change.type == .modified {
                let index = getSleepDataIndexByID(sleepDataID)!
                sleepDataList[index] = sleepData
            }
            else if change.type == .removed {
                if let index = getSleepDataIndexByID(sleepDataID) {
                    sleepDataList.remove(at: index)
                }
            }
        }

        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user ||
                listener.listenerType == ListenerType.all {
                
                listener.onUserChange(change: .update, newData: currentUser)
            }
        }
    }
    
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot) {
        currentUser      = User()
        currentUser?.name = snapshot.data()["name"] as! String
        currentUser?.email = snapshot.data()["email"] as! String
        currentUser?.id   = snapshot.documentID
        
        print("Here is the user id: \(String(describing: currentUser?.id))")

        if let sleepDataReferences = snapshot.data()["sleepData"] as? [DocumentReference] {
            // If the document has a "heroes" field, add heroes.
            for reference in sleepDataReferences {
                if let sleepData = getSleepDataByID(reference.documentID) {
                    currentUser?.sleepData.append(sleepData)
                }
            }
            
        }

        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user ||
            listener.listenerType == ListenerType.all {
                listener.onUserChange(change: .update, newData: currentUser!)
            }
        }
    }
    
    
    func getSleepDataIndexByID(_ id: String) -> Int? {
        if let sleepData = getSleepDataByID(id) {
            return sleepDataList.firstIndex(of: sleepData)
        }
        return nil
    }
    
    
    func getSleepDataByID(_ id: String) -> SleepData? {
        for sleepData in sleepDataList {
            if sleepData.id == id{
                return sleepData
            }
        }
        return nil
    }
    
    
    func cleanup() {}
    
    
    func addSleepData(duration: Int) -> SleepData {
        let sleepData = SleepData()
        sleepData.durationInSec = Int(duration)
        
        do {
            if let sleepDataRef = try sleepDataRef?.addDocument(from: sleepData) {
                sleepData.id = sleepDataRef.documentID
                print("Successfully add Sleep Data: ", sleepData.id as Any)
            }
        } catch {
            print("Faild to serialize Sleep Data")
        }
        
        
        return sleepData
    }
    
    
    func addUser(name: String, email: String) -> User {
        let user  = User()
        user.name = name
        user.email = email
        
        if let userRef = userRef?.addDocument(data: ["name": name, "email": email, "sleepData": []]) {
            user.id = userRef.documentID
        }
        
        return user
    }
    
    
    func addSleepDataToUser(sleepData: SleepData, user: User) -> Bool {
        
        let sleepDataID = sleepData.id
        let userID      = user.id
        
        if let newSleepDataRef = sleepDataRef?.document(sleepDataID!) {
            userRef?.document(userID!).updateData(
                ["sleepData": FieldValue.arrayUnion([newSleepDataRef])]
            )
        }
        return true
    }
    
    
    func deleteSleepData(sleepData: SleepData) {
        if let sleepDataID = sleepData.id {
            sleepDataRef?.document(sleepDataID).delete()
        }
    }
    
    
    func deleteUser(user: User) {
        if let userID = user.id {
            userRef?.document(userID).delete()
        }
    }
    
    
    func removeSleepDataFromUser(sleepData: SleepData, user: User) {
        if user.sleepData.contains(sleepData), let userID = user.id,
            let sleepDataID = sleepData.id {
            
            if let removeRef = sleepDataRef?.document(sleepDataID) {
                userRef?.document(userID).updateData(
                    ["sleepData": FieldValue.arrayRemove([removeRef])]
                )
            }
        }
        
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.sleep ||
            listener.listenerType == ListenerType.all {
            print("Fot test \(sleepDataList.count)")
            listener.onSleepChange(change: .update, sleepData: sleepDataList)
        }
        
        if listener.listenerType == ListenerType.user ||
            listener.listenerType == ListenerType.all {
            listener.onUserChange(change: .update, newData: currentUser)
        }
    }
    
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func addDummyForDefaultUser(){
        
        // 3 5 10 8 4 11 6
        
        let sleep1 = addSleepData(duration: 6 * 3600)
        
        let sleep2 = addSleepData(duration: 6 * 3600)
        
        let sleep3 = addSleepData(duration: 6 * 3600)
        
        let sleep4 = addSleepData(duration: 6 * 3600)
       
        let sleep5 = addSleepData(duration: 6 * 3600)
        
        let sleep6 = addSleepData(duration: 10 * 3600)
        
        let sleep7 = addSleepData(duration: 6 * 3600)
        
        
        _ = addSleepDataToUser(sleepData: sleep1, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep2, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep3, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep4, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep5, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep6, user: currentUser!)
        _ = addSleepDataToUser(sleepData: sleep7, user: currentUser!)
    }
    
}
