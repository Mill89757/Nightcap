//
//  UserLogInViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 25/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SettingsCell"

class UserLogInViewController: UIViewController {
    
    
    // MARK: - Properties
    var appDelegate: AppDelegate?
    weak var databaseController: DatabaseProtocol?
    
    var freeAccountFrame: CGRect?
    var userAccountFrame: CGRect?

    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    
    
    // MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        // Hide back button
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = self.appDelegate!.databaseController
        
        configureUI()
    }

    
    // MARK: - Helper Functions
    func configureTableView() {
        tableView                 = UITableView()
        tableView.backgroundColor = UIColor.darkGray
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.rowHeight       = 60
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        // Set frame for header
        var frame: CGRect?
        frame = CGRect(x: 0, y: 88, width: self.view.frame.width, height: 100)
    
        userInfoHeader            = UserInfoHeader(frame: frame!,user: self.appDelegate?.user, defaultHeader: false)
        tableView.tableHeaderView = userInfoHeader          // Create the user Header
        
        tableView.tableFooterView = UIView()
    }
    
    
    func configureUI() {
        configureTableView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent      = false
        navigationController?.navigationBar.barStyle           = .black
        navigationController?.navigationBar.barTintColor       = UIColor(red: 79/255, green: 148/255, blue: 205/255, alpha: 1)
        navigationItem.title                                   = "Settings"
        navigationItem.largeTitleDisplayMode                   = .automatic
        navigationController?.navigationBar.sizeToFit()
    }
}

extension UserLogInViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingSection(rawValue: section) else {return 0}
        
        switch section {
        case .Account:
            return AccountOptions.allCases.count-1
        case .Alarm:
            return AlarmOptions.allCases.count
        }
    }
    
    
    func tableView(_ tableview: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.black
    
        let title            = UILabel()
        title.font           = UIFont.boldSystemFont(ofSize: 16)
        title.textColor      = .white
        title.text           = SettingSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints                              = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive         = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        cell.backgroundColor = UIColor.lightGray
        
        guard let section = SettingSection(rawValue: indexPath.section) else {return UITableViewCell() }
        
        switch section {
        case .Account:
            let account      = AccountOptions(rawValue: indexPath.row)
            cell.sectionType = account
            cell.textLabel?.text = "Log Out"
        case .Alarm:
            let alarm        = AlarmOptions(rawValue: indexPath.row)
            cell.sectionType = alarm
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = SettingSection(rawValue: indexPath.section) else {return }
        
        switch section {
        case .Account:
            // Handle log out function
            let accountOption = AccountOptions(rawValue: indexPath.row)
            if accountOption?.description == "Log Out"{
                logOut()
            }
        case .Alarm:
            let alarmOption = AlarmOptions(rawValue: indexPath.row)
            if alarmOption?.description == "Change Alarm Sound"{
                changeAlarmSound()
            }
        }
    }
    
    
    func changeAlarmSound(){
        let vc = self.storyboard?.instantiateViewController(identifier: "ModifyAlarmSoundTableViewController") as? ModifyAlarmSoundTableViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func logOut(){
        
        // Once log out, convert to default user
        let defaultUser = databaseController?.fetchSpecificUser(email: "Default")
        self.appDelegate?.user = defaultUser
        
        print("After logout - user: \(String(describing: defaultUser?.name))")
        
        let vc = self.storyboard?.instantiateViewController(identifier: "UserLogOutViewController") as? UserLogOutViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}
