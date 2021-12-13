//
//  SummaryViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 Reference
 
 Cirecle Label: https://github.com/andriadze/CircleLabel
 
 
 */


import UIKit
import CircleLabel

class SummaryViewController: UIViewController, DatabaseListener {
    
    var currentUser: User?
    
    func onUserChange(change: DatabaseChange, newData: User?) {
        //MacawChartView.updateAnimations()
    }
    
    var listenerType: ListenerType = .user

    @IBOutlet weak var chartView: MacawChartView!
    @IBOutlet weak var pieChartView: MacawCircleView!
    @IBOutlet weak var sleepDataBoardLabel: UILabel!
    @IBOutlet weak var lastSleepDataLabel: CircleLabel!
    @IBOutlet weak var todaySleepLabel: CircleLabel!
    @IBOutlet weak var lastSleepPromptLabel: UILabel!
    @IBOutlet weak var todaySleepPromptLabel: UILabel!
    
    let SECTION_LAST_SLEEP = 0
    let SECTION_TOTAL_SLEEP = 1
    
    weak var databaseController: DatabaseProtocol?

    let appDelegate    = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        navigationController?.setNavigationBarHidden(true, animated: animated)
        databaseController?.addListener(listener: self)
        MacawChartView.playAnimations()
        pieChartView.updateCircle(newExtent: [appDelegate.sleepSpeed, appDelegate.neeedSleepTime, appDelegate.sleepAtTime])
        pieChartView.play()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.contentMode = .scaleAspectFit
    
        databaseController = appDelegate.databaseController

        sleepDataBoardLabel.layer.cornerRadius      = 10
        sleepDataBoardLabel.layer.masksToBounds     = true
        
        lastSleepPromptLabel.layer.cornerRadius     = 15
        lastSleepPromptLabel.layer.masksToBounds    = true
        
        todaySleepPromptLabel.layer.cornerRadius    = 15
        todaySleepPromptLabel.layer.masksToBounds   = true
        
        lastSleepDataLabel.text = "00 h  00 m"
        lastSleepDataLabel.circleColor = UIColor.blue
        
        todaySleepLabel.text = "00 h  00 m"
        todaySleepLabel.circleColor = UIColor.blue
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func onSleepChange(change: DatabaseChange, sleepData: [SleepData]) {
        
        print("length of last sleep data: \(appDelegate.lastSleep)")
        print("length of all sleep: \(appDelegate.todaySleep)")
        
        //update last sleep
        var lastSleepData = appDelegate.lastSleep
        var hour          = lastSleepData / 3600
        lastSleepData = lastSleepData - hour * 3600
        var min           = lastSleepData / 60
            
        lastSleepDataLabel.text = "\(hour) h \(min) m"

        // update for current day sleep time
        var todaySleepData = appDelegate.todaySleep
        hour          = todaySleepData / 3600
        todaySleepData = todaySleepData - hour * 3600
        min           = todaySleepData / 60
        
        todaySleepLabel.text = "\(hour) h \(min) m"
    }
    
    
}

