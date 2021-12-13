//
//  LogInRegisterViewController.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 10/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInRegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    
    var oneUser: Bool = false           // avoid view controller automatically dismiss
    
    var appDelegate: AppDelegate?
    weak var databaseController: DatabaseProtocol?
    
    
    @IBAction func registerAccount(_ sender: Any) {
        
        // Handle user input user name
        guard let username = usernameTextField.text else {
            displayMessage("Please enter a username")
            return
        }
        
        // Handle user input password
        guard let password = passwordTextField.text else {
            displayMessage("Please enter a password")
            return
        }
        
        // Handle user input unique email address
        guard let email = emailTextField.text else {
            displayMessage("please enter an email address")
            return
        }
        
        // Create user to program
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayMessage(error.localizedDescription)
            }
        }
        self.oneUser           = true
        // Update user to app and database
        let currentUser        = self.databaseController?.addUser(name: username, email: email)
        self.appDelegate?.user = currentUser
        
            
        print("Rgister successfully, new app user is \(String(describing: currentUser?.name))")
    }
    
    
    @IBAction func loginToAccount(_ sender: Any) {
        
        // Handle user input password
        guard let password = passwordTextField.text else {
            displayMessage("Please enter a password")
            return
        }
        
        // Handle user input email address
        guard let email = emailTextField.text else {
            displayMessage("please enter an email address")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.displayMessage(error.localizedDescription)
            }else{
                print("Log in successfully")
                
                
            }
        }
        let oldUser = self.appDelegate?.user
        // Depend on unique email address, fetch this user info
        let newUser = self.databaseController?.fetchSpecificUser(email: email)
        self.appDelegate?.user = newUser
        
        
        print("New application User change from \(String(describing: oldUser?.name)) to \(String(describing: newUser?.name)) ")
        self.oneUser = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "Optional for Log In",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        // Handle authantication and transact to log in view controller
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if self.oneUser == true{
                self.oneUser = false
                
                let vc = self.storyboard?.instantiateViewController(identifier: "UserLogInViewController") as? UserLogInViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate    = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        self.appDelegate   = UIApplication.shared.delegate as? AppDelegate
        databaseController = self.appDelegate!.databaseController
        
    }
    

    func displayMessage(_ errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return pressed")
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        
        return false
    }
}
