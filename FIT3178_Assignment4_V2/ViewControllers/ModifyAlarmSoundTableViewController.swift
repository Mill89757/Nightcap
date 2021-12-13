//
//  ModifyAlarmSoundTableViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 27/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ModifyAlarmSoundTableViewController: UITableViewController {
    
    
    let soundName = ["Driven To Success", "Moonrise", "Storybook"]
    let soundInventory = ["Driven_To_Success", "moonrise", "storybook"]
    
    var alarmAudioPlayer      = AVAudioPlayer()
    var lastSoundIndex: IndexPath?
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.alarmAudioPlayer.stop()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundInventory.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = soundName[indexPath.row]
        
        if indexPath.row == 2 {
            self.lastSoundIndex = indexPath
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do
        {
            self.alarmAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: self.soundInventory[indexPath.row], ofType: "mp3")!))
            self.alarmAudioPlayer.play()
        }catch{
            print(error)
        }
        // change application alarm sound
        self.appDelegate.alarmSound = self.soundInventory[indexPath.row]
        print("Application alarm sound has changed to \(soundName[indexPath.row])")
        
        // Update tick mark
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
        
        tableView.cellForRow(at: lastSoundIndex!)?.accessoryType = UITableViewCell.AccessoryType.none
        self.lastSoundIndex = indexPath
    }
}
