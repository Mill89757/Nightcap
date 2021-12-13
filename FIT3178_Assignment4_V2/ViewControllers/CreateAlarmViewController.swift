//
//  CreateAlarmViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 Reference
 
 Solar - Github Link:   https://github.com/ceeK/Solar
 TransitionButton: Github Link:     https://github.com/AladinWay/TransitionButton
 
 
 */

import UIKit
import CoreLocation
import Solar
import TransitionButton
import QuartzCore


class CreateAlarmViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, DatabaseListener{
    
    var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .user
    
    func onSleepChange(change: DatabaseChange, sleepData: [SleepData]) {
    }
    
    func onUserChange(change: DatabaseChange, newData: User?) {
        appDelegate?.user = newData
        print("updated user to create alarm ", newData?.sleepData.count as Any)
        print(appDelegate?.user?.name as Any)
    }
    
    var locationManager = CLLocationManager()           // Handle Location Function
    
    var SUN_RISE: Date?                                 // Today sun rise time
    var SUN_SET: Date?                                  // Today sun set time
    var NEXT_SUN_RISE: Date?                            // Tommorrow sun rise time
    var NEXT_SUN_SET: Date?                             // Tommorrow sun set time
    
    var weakup_time: Date?
    var sleeptime: Int?
    
    var appDelegate: AppDelegate?
    let COMPONENT_HOUR = 0
    let COMPONENT_MINUTE = 1
    let COMPONENT_TYPE = 2
    
    
    let hours = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
    //let hours = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
    let minutes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
    let type = ["AM", "PM"]

    @IBOutlet weak var weakUpTimeLabel: UILabel!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var sleepButton: UIButton!
    @IBOutlet weak var typeSwith: UISegmentedControl!
    @IBOutlet weak var sunTimeLabel: UILabel!
    @IBOutlet weak var alarmModeSwitch: UISegmentedControl!
    
    var weakUpHour = ""
    var weakUpMinute = ""
    var timeType = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Hello create alarm controller")
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        timePickerView.isHidden = true
        databaseController?.addListener(listener: self)
    }
    
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        super.viewDidLoad()
        // sleepButton.isHidden = true
        databaseController = appDelegate!.databaseController
        
        // set alarm mode
        self.appDelegate?.alarmMode = Mode.allCases[alarmModeSwitch.selectedSegmentIndex]
        
        timePickerView.dataSource = self
        timePickerView.delegate   = self
        timePickerView.isHidden   = true
        
        // Do any additional setup after loading the view.
        // weakUpTimeLabel.text =  "07 : 30"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateAlarmViewController.tapLabel))
        weakUpTimeLabel.isUserInteractionEnabled = true
        weakUpTimeLabel.addGestureRecognizer(tap)
    
        askSunTime()                        // Update sun set and sun rise time
        
        self.weakUpHour   = "7"
        self.weakUpMinute = "30"
        self.timeType     = "AM"
        
        weakUpTimeLabel.text = self.weakUpHour + " : " + self.weakUpMinute + " " + self.timeType
        
        weakUpTimeLabel.layer.cornerRadius = 20
        weakUpTimeLabel.layer.masksToBounds = true
        alarmModeSwitch.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: UIControl.State.normal)
    }
    
    
    @objc func tapLabel(){
        timePickerView.isHidden = false
    }
    
    // Handle User click sleep button
    @IBAction func sleepNow(_ button: TransitionButton) {
        button.startAnimation()
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(2)            // Play animations 2 seconds
            self.prepareToSleep()

            DispatchQueue.main.async(execute: { () -> Void in
                button.stopAnimation(animationStyle: .expand, completion: {
                let vc = self.storyboard?.instantiateViewController(identifier: "SleepViewController") as? SleepViewController
                vc?.sleeptime = self.sleeptime!
                vc?.modalPresentationStyle = .fullScreen
                self.present(vc!, animated: true, completion: nil)
                
                })
            })
        })
    }
    
    
    func prepareToSleep(){
        // Handle Sleep time here
        
        let currentDate      = Date()
        let calendar         = Calendar.current
        var currentHour      = calendar.component(.hour, from: currentDate)
        let currentMin       = calendar.component(.minute, from: currentDate)
        if currentHour >= 12{
            currentHour -= 12
        }
        let currentTimeAsSecond = (currentHour*60*60)+(currentMin*60) //00:00
            
        let formatter        = DateFormatter()
        formatter.dateFormat = "hh:mm aa"
        let currenttime      = formatter.string(from: currentDate)
                
        
        let _: String.Index     = currenttime.startIndex
        let endIndex: String.Index       = currenttime.endIndex
        let typeStartIndex: String.Index = currenttime.index(currenttime.startIndex, offsetBy:6)

        var type: String?
                
        let offsetRange = typeStartIndex ..< endIndex
        if String(currenttime[offsetRange]) == "am"{
            type = "AM"
        }else{
            type = "PM"
        }
            
        print("current hour: \(currentHour) current min: \(currentMin) type: \(String(describing: type))")
        print("currentTime as second: \(currentTimeAsSecond)")
            
        let setHour             = Int(self.weakUpHour)
        let setMin              = Int(self.weakUpMinute)
        let setTimeAsSecond:Int = setHour!*60*60 + setMin!*60
        print("set hour: \(String(describing: setHour)) set min: \(String(describing: setMin)) time type: " + self.timeType)
        print("set time as second: \(setTimeAsSecond)")
            
        if currentTimeAsSecond == setTimeAsSecond {
            if timeType == type {
                sleeptime = (60 * 60 * 24)
            }else{
                sleeptime = (60 * 60 * 12)
            }
        }
        else if setTimeAsSecond < currentTimeAsSecond{
            if timeType == type {
                sleeptime = (60 * 60 * 24) - (currentTimeAsSecond - setTimeAsSecond)
            }else{
                sleeptime = (60 * 60 * 12) - (currentTimeAsSecond - setTimeAsSecond)
            }
        }
        else{
            sleeptime = setTimeAsSecond - currentTimeAsSecond
        }
        print("Sleep time \(Int(sleeptime!/60))")
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.weakUpHour   = hours[pickerView.selectedRow(inComponent: COMPONENT_HOUR)]
        self.weakUpMinute = minutes[pickerView.selectedRow(inComponent: COMPONENT_MINUTE)]
        self.timeType     = type[pickerView.selectedRow(inComponent: COMPONENT_TYPE)]
    
        weakUpTimeLabel.text = weakUpHour + " : " + weakUpMinute + " " + timeType
    }
        
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == COMPONENT_HOUR {
            return hours[row]
        }else if component == COMPONENT_TYPE{
            return type[row]
        }
        return minutes[row]
    }

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == COMPONENT_HOUR {
            return hours.count
        }else if component == COMPONENT_TYPE {
            return 2
        }
        return minutes.count
    }
}


extension CreateAlarmViewController: CLLocationManagerDelegate {

    func askSunTime(){
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                // Authorized
                let lat      = locationManager.location?.coordinate.latitude
                let long     = locationManager.location?.coordinate.longitude
                let location = CLLocation(latitude: lat!, longitude: long!)
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    if error != nil {
                        return
                    } else if let country  = placemarks?.first?.country, let city = placemarks?.first?.locality {
                        print(country)
                        print(city)

                    
                        let date = Date()
                        
                        // Get next day
                        var dayComponent = DateComponents()
                        dayComponent.day = 1
                        let cal = Calendar.current
                        let nextDate = cal.date(byAdding: dayComponent, to: date)
                        print("Next Date \(String(describing: nextDate))")
                        
                        (self.SUN_RISE, self.SUN_SET) = self.getSunTime(date: date, lat: lat!, long: long!)
                        (self.NEXT_SUN_RISE, self.NEXT_SUN_SET) = self.getSunTime(date: nextDate!, lat: lat!, long: long!)
                        
                        self.updateSunTime()
                    }
                })
            case .notDetermined, .restricted, .denied:
                print("Error: Either Not Determined, Restricted, or Denied. ")
                break
            default:
                print("Default Error")
                break
            }
        }
    }
    
    // Get specific sun set and sun rise time
    func getSunTime(date: Date, lat: CLLocationDegrees, long: CLLocationDegrees) -> (Date, Date){
        
        var local_sunrise: String?
        var local_sunset: String?
        
        let solar = Solar(for: date, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        
        let sunrise_utc = solar?.sunrise
        let sunset_utc  = solar?.sunset
        
        let formatter         = DateFormatter()
        formatter.dateFormat  = "yyyy-MM-dd HH:mm:ss Z"
        var sourceDate        = sunrise_utc
        let formatter2        = DateFormatter()
        formatter2.dateFormat = "MMM dd @hh:mm aa"
        local_sunrise         = formatter2.string(from: sourceDate! as Date)
        print("local sunrise time: ",local_sunrise as Any)
        
        sourceDate            = sunset_utc
        formatter2.dateFormat = "MMM dd @hh:mm aa"
        local_sunset          = formatter2.string(from: sourceDate! as Date)
        print("local sunset time: ",local_sunset as Any)
        
        let date_sunrise = formatter2.date(from: local_sunrise!)!
        let date_sunset  = formatter2.date(from: local_sunset!)!
        
        return (date_sunrise, date_sunset)
    }
    
    
    // Update sun set time or sun rise time to screen
    func updateSunTime(){
        var diff = 0
        
        let date             = Date()
        let formatter        = DateFormatter()
        formatter.dateFormat = "MMM dd @hh:mm aa"
        let current          = formatter.string(from: date)
        let cal              = Calendar.current
        let now              = formatter.date(from: current)
        
        if SUN_RISE != nil && SUN_SET != nil {
        
            if now?.compare(SUN_RISE!) == .orderedAscending{
                let components = cal.dateComponents([.hour], from: now!, to: SUN_RISE!)
                diff = components.hour!
                if diff < 1{
                    sunTimeLabel.text = "It almost dawn"
                }else {
                    sunTimeLabel.text = "Sun rise: \(diff) h"
                }
            }
            else if now?.compare(SUN_SET!) == .orderedAscending{
                let components = cal.dateComponents([.hour], from: now!, to: SUN_SET!)
                diff = components.hour!
                if diff < 1{
                    sunTimeLabel.text = "It's getting drak"
                }else{
                    sunTimeLabel.text = "Sun set: \(diff) h"
                }
            }else{
               let components = cal.dateComponents([.hour], from: now!, to: NEXT_SUN_RISE!)
                diff = components.hour!
                if diff < 1{
                    sunTimeLabel.text = "It almost dawn"
                }else {
                    sunTimeLabel.text = "Sun rise: \(diff) h"
                }
            }
        }else{
            print(" Sun time got Error")
        }
    }
        
}
