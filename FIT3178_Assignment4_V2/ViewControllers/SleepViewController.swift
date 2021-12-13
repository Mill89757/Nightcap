//
//  SleepViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 
 */

import UIKit
import AVFoundation
import AVKit
import UserNotifications
import CoreMotion


class SleepViewController: UIViewController, UIScrollViewDelegate {
    
    // Motion app allocation
    var xValues: [Double] = []
    var yValues: [Double] = []
    var zValues: [Double] = []
    let motionManager: CMMotionManager = CMMotionManager()
    
    // Sound realted data
    var SOUND_INDEX = 1
    var isPlaying:           Bool    = false        // check whether whitenoise is play or not
    var currentImageIndex            = 1            // white noise index
    var images:             [String] = ["0", "1", "2"]
    var sounds:             [String] = ["fire_burning", "sea", "nature_rain"]
    var soundPlayImageView: [String] = ["fire_play", "wave_play", "rain_play"]
    var soundStopImageView: [String] = ["fire_stop", "wave_stop", "rain_stop"]
    var whiteNoiseAudioPlayer = AVAudioPlayer()
    var alarmAudioPlayer      = AVAudioPlayer()
    
    // Timer - three speparate work
    var motionTimer: Timer?
    var updateTimer: Timer?
    var progressTimer : Timer!
    
    // Sleep stauts attributes
    var sleeptime = 0
    var progress : CGFloat! = 0
    var isSleeping = true
    var fallSleepTime: Int = 0
    var sleepSpeed: Double = 5
    
    var animatedButton : AnimatedButton!
    
    weak var databaseController: DatabaseProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var soundImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if whiteNoiseAudioPlayer.isPlaying{
            whiteNoiseAudioPlayer.stop()
            isPlaying = false
            //soundLabel.textColor = .black
            soundImageView.image = UIImage(named: soundStopImageView[SOUND_INDEX])
        } else{
            whiteNoiseAudioPlayer.play()
            isPlaying = true
            // soundLabel.textColor = .white
            soundImageView.image = UIImage(named: soundPlayImageView[SOUND_INDEX])
        }
    }
    
    
    @IBAction func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left && SOUND_INDEX <= images.count - 2{
            SOUND_INDEX += 1
        } else if recognizer.direction == .right && SOUND_INDEX >= 1 {
            SOUND_INDEX -= 1
        }
        
        do {
            whiteNoiseAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: sounds[SOUND_INDEX], ofType: "mp3")!))
        } catch {
            print(error)
        }
        if isPlaying{
            soundImageView.image = UIImage(named: soundPlayImageView[SOUND_INDEX])
            whiteNoiseAudioPlayer.play()
        }else{
            soundImageView.image = UIImage(named: soundStopImageView[SOUND_INDEX])
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Sleep time from user choosen \(sleeptime)")
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        
        goToSleep()         // User prepare to sleep, alarm start to work
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        self.isSleeping = false
        
        // Cancle Timer and motion detection
        self.motionTimer?.invalidate()
        self.updateTimer?.invalidate()
        self.motionManager.stopDeviceMotionUpdates()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor().colorFromHex("00a99d")
        
        if appDelegate.notificationsEnabled {
            UNUserNotificationCenter.current().delegate = self
        }
    
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // set up back button
        animatedButton        = AnimatedButton(frame: CGRect(x: 0,y: 0,width: 100,height: 100), viewController: self)
        animatedButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + self.view.center.y * 0.6)
        animatedButton.progressColor     = .red
        animatedButton.closeWhenFinished = false
        animatedButton.addTarget(self, action: #selector(SleepViewController.record), for: .touchDown)
        animatedButton.addTarget(self, action: #selector(SleepViewController.stop), for: UIControl.Event.touchUpInside)
        animatedButton.center.x = self.view.center.x
        view.addSubview(animatedButton)
        
        let appDelegate    = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Create a updated time label for screen
        let now      = Date()
        let calendar = Calendar.current
        
        let hour     = calendar.component(.hour, from: now)
        let minute   = calendar.component(.minute, from: now)

        if minute >= 10 {
            timeLabel.text = "\(hour) : \(minute)"
        } else {
            timeLabel.text = "\(hour) : 0\(minute)"
        }
        
        // Initialize motion timer
        var runCount = 0
        var avgMotionValue = 0.0
        print("Start to detect sleep...")
        self.motionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            runCount += 1
            self.fallSleepTime += 1
            self.motionManager.deviceMotionUpdateInterval = 1/30
            self.motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion(data:error:))
            
            // 3 mins Motion Detectio to analyze user sleep status
            if runCount == 180 {
                
                // Analyze Sleep Motion Data
                var sum1 = 0.0
                var sum2 = 0.0
                var sum3 = 0.0

                var sum = 0.0

                for num in self.zValues {
                    sum1 += num
                }
                print("Sum Z values: \(sum1)")

                for num in self.xValues {
                    sum2 += num
                }
                print("Sum X values: \(sum2)")

                for num in self.yValues {
                    sum3 += num
                }
                print("Sum Y values: \(sum3)")

                sum = sum1 +  sum2 + sum3
                avgMotionValue = Double(sum)/Double(self.zValues.count)
                print("Motion avg value: \(avgMotionValue)")
                
                if avgMotionValue < -0.90 {
                    print("Motion timer has been terminated")
                    print("User fall asleep - fall sleep time: \(self.fallSleepTime)")
                    timer.invalidate()
                    self.motionManager.stopDeviceMotionUpdates()
                    
                } else{
                    print("Not fall in sleep, detect again")
                    runCount = 0
                    if self.sleepSpeed >= 1{
                        self.sleepSpeed -= 1
                    }
                }
            }
        }
        
        // Initialize updated time timer
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getCurrentTime), userInfo: nil, repeats: true)
        
        // Set white noise player
        do {
            whiteNoiseAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: sounds[currentImageIndex], ofType: "mp3")!))
            
            whiteNoiseAudioPlayer.numberOfLoops = -1        // play in infinite loop
            whiteNoiseAudioPlayer.prepareToPlay()
            
            let audioSession = AVAudioSession.sharedInstance()
                   
            do{
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }catch{
                 print(error)
            }
        } catch {
            print(error)
        }
        
        // Updated sound image for screen
        soundImageView.image = UIImage(named: soundStopImageView[SOUND_INDEX])
        
        // Modify sleep time under smart mode
        let sleepCycle:Int   = 5400
        print("\nCurrent alarm Mode is \(appDelegate.alarmMode)")
        if appDelegate.alarmMode == Mode.Smart {
            
            if sleeptime >= sleepCycle {
                sleeptime = sleeptime - sleeptime % sleepCycle
                print("Smart Sleep Time: \(sleeptime)")
            }
        }
    }

    
    @objc func getCurrentTime(){
        let date     = Date()               // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour     = calendar.component(.hour, from: date)
        let minute   = calendar.component(.minute, from: date)
        
        if minute >= 10 {
            timeLabel.text = "\(hour) : \(minute)"
        } else {
            timeLabel.text = "\(hour) : 0\(minute)"
        }
    }
    
    
    @IBAction func stopSleep(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func record() {
        progress = 0
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(SleepViewController.updateProgress), userInfo: nil, repeats: true)
    }
    
    
    @objc func updateProgress() {
        
        let maxDuration = CGFloat(5) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        animatedButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
        }
    }
    
    // Handle user exist sleep view and store data
    @objc func stop() {
        self.progressTimer.invalidate()
        if progress >= 1 {
            self.dismiss(animated: true, completion: nil)
            whiteNoiseAudioPlayer.stop()
            isPlaying = false
            
            // At least 3 mins sleep will be record under No alarm mode
            if appDelegate.alarmMode == Mode.NoAlarm && sleeptime >= 180 {
                let realSleepTime = self.sleeptime -  self.fallSleepTime
                
                // Generate sleep and store data under Smart Mode and Normal Mode
                let sleepData = self.databaseController?.addSleepData(duration: self.sleeptime)
                
                // Add this sleep data to user
                let _ = self.databaseController?.addSleepDataToUser(sleepData: sleepData!, user: self.appDelegate.user!)
                self.appDelegate.sleepSpeed = self.sleepSpeed
                                
                print("\(realSleepTime) seconds sleep has been recorded to user \(String(describing: self.appDelegate.user?.name))")
                                
                // Update summary time
                self.appDelegate.todaySleep = self.sleeptime
                self.appDelegate.lastSleep = self.sleeptime
                
                let _ = self.databaseController?.addSleepData(duration: self.sleeptime)
                print("\(self.sleeptime) seconds sleep has been recorded")
            }
        }
    }
    
    
    func handleMotion(data: CMDeviceMotion?, error: Error?) -> Void {
        
        guard let data = data else {
            print("Motion failure: \(String(describing: error))")
            return
        }
        xValues.append(Double(data.gravity.x))
        yValues.append(Double(data.gravity.y))
        zValues.append(Double(data.gravity.z))
        print("X: \(data.gravity.x), Y: \(data.gravity.y), Z: \(data.gravity.z)")
    }
    
    
    func goToSleep () {
        // sleep time must be valid and No Alarm mode do not need alarm
        if sleeptime >= 1 && appDelegate.alarmMode != Mode.NoAlarm{
            
            // Prepare alarm
            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(sleeptime)){
                self.whiteNoiseAudioPlayer.stop()
                do{
                    self.alarmAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: self.appDelegate.alarmSound, ofType: "mp3")!))
                           
                    let audioSession = AVAudioSession.sharedInstance()
    
                    do{
                        try audioSession.setCategory(AVAudioSession.Category.playback)
                    }catch{
                        print(error)
                    }
                }catch{
                    print(error)
                }
                if self.isSleeping {
                    self.alarmAudioPlayer.play()
                    self.alarmAudioPlayer.numberOfLoops = -1        // play infinite loop
                    let alert = UIAlertController(title: "Alarm", message: "Click 'OK' Button", preferredStyle: UIAlertController.Style.alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler: { (UIAlertAction) in
                            
                            self.alarmAudioPlayer.stop()
                            self.whiteNoiseAudioPlayer.stop()
                            self.isPlaying = false
                        })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true)
                }
            }
        }
    }
}


extension SleepViewController: UNUserNotificationCenterDelegate{
    
    func advancedNotificationAction() {
        guard appDelegate.notificationsEnabled else {
            print("Notifications not enabled")
            return
        }

        let content = UNMutableNotificationContent()
        
        content.title = "Something has happened"
        content.body = "Tap to respond..."
        
        content.categoryIdentifier = AppDelegate.CATEGORY_IDENTIFIER
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "foo", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        self.alarmAudioPlayer.play()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // The app is active, how do we want to handle notification.
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.notification.request.content.categoryIdentifier {
        // If a general notification then break. We do not need to handle it
        case "GENERAL":
            print("General notification ignore")
            break
        // Only handle our current identifier
        case AppDelegate.CATEGORY_IDENTIFIER:
            
            switch response.actionIdentifier {
            case "decline":
                print("declined")
                break
            case "accept":
                print("accepted")
                self.alarmAudioPlayer.stop()
                self.isPlaying = false
                break
            case "comment":
                // In this case we know that it is a user response instead. So we can cast it to get the response
                let userResponse = response as! UNTextInputNotificationResponse
                print(userResponse.userText)
                break
            default:
                break
            }
            
        default:
            break
        }
        completionHandler()
    }
}


extension UIColor {
    
    func colorFromHex(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return UIColor.black
        }
        
        var rgb: UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                            blue: CGFloat((rgb & 0x0000FF)) / 255.0,
                            alpha: 1.0)
    }
}
