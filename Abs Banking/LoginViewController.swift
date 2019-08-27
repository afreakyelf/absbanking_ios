//
//  LoginViewController.swift
//  Abs Banking
//
//  Created by apple on 19/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAuth
let ip = "localhost:9595"

func checkInternet(_ viewcontroller: UIViewController){
    if !NetworkHelper.isConnectedToNetwork(){
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check you mobile data or Wifi", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive, handler: nil))
        viewcontroller.self.present(alert, animated: true, completion: nil)
        return
    }
}


class LoginViewController: UIViewController,UITextFieldDelegate  {

    
    @IBOutlet weak var wrongpass: UILabel!
    @IBOutlet weak var userdnne: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
//  let ip = "172.20.2.79:9696"

    @IBAction func blah(_ sender: Any) {
    }
    
    
    var mobileNumber = 0
    var pBool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkInternet(self)

        
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        loginIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        loginIndicator.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
        
        
        loginIndicator.color = UIColor.white
            
        self.userName.delegate = self
        self.password.delegate = self
        // Do any additional setup after loading the view.
        
        self.userName.addTarget(self, action: #selector(userNameClick), for: .editingChanged)
        self.password.addTarget(self, action: #selector(passwordClick), for: .editingChanged)

        
    }
  
    @IBAction func login(_ sender: Any) {
        
        checkInternet(self)

        
        animate(1)
        loginButton.alpha = 0
        
        let userEnteredPwd = self.password.text!
        
        let userName = Int(self.userName.text!)
        
        if userName == nil {
            return
        }
        
        let urlForAuth = "http://\(ip)/details/getPasswd?acc_no=\(userName!)"
        print(urlForAuth)
        var password : String?
        var acc_no : String?
        
        let defaults = UserDefaults.standard

        
        AF.request(urlForAuth).responseJSON {
            (responseData) -> Void in
            let jsonData = JSON(responseData.data as Any)
            password = jsonData["passwd"].stringValue
            self.mobileNumber = jsonData["phone"].intValue
            acc_no = "\(jsonData["acc_no"].intValue)"
            print(self.mobileNumber)
            
            if password! == "" {
                print("Enter does not exist")
                self.animate(0)
                self.loginButton.alpha = 1
                self.userdnne.alpha = 1

            }else if password! ==  userEnteredPwd {
                
                var passwordd : String?
                
                if defaults.string(forKey: String(self.mobileNumber)) != nil {
                    passwordd = defaults.string(forKey: String(self.mobileNumber))!
                    print(passwordd!)
                }
    
                if(passwordd == userEnteredPwd ){
                    print("same device")
                    let homePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
                    
                    print("Sending value \(acc_no!)")
                    homePage.accNumber = Int(acc_no!)
                    self.navigationController?.pushViewController(homePage, animated: true)
                    
                    self.animate(0)
                    self.loginButton.alpha = 1
                    
                }else{
                    print("New device")
                    print("Error Matching password")
                    self.verifyDevice(self.mobileNumber,userEnteredPwd)
                    
                    self.animate(0)
                    self.loginButton.alpha = 1
                }
                
                UserDefaults.standard.set(acc_no!, forKey: "accountNo")

                
            }else{
                print("Error")
                self.animate(0)
                self.loginButton.alpha = 1
                self.wrongpass.alpha = 1
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.userName.delegate = self
        self.password.delegate = self
        
    }
    
    func verifyDevice(_ username: Int,_ pwd : String) {
        
        let alertController = UIAlertController(title: "New Device Verification", message: "Please verify your device on next screen", preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            let newdevice = self.storyboard?.instantiateViewController(withIdentifier: "NewDeviceVerificationViewController") as! NewDeviceVerificationViewController
            newdevice.mobileNumber = username
            newdevice.password = pwd
            self.navigationController?.pushViewController(newdevice, animated: true)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }

  
    func animate(_ int : Int){
        self.loginIndicator.alpha = CGFloat(int)
        if(int==1){
            self.loginIndicator.startAnimating()
        }else{
            self.loginIndicator.stopAnimating()
        }
    }

    @objc
    func userNameClick(_ userName : UITextField){
        self.userdnne.alpha = 0
    }
    
    @objc
    func passwordClick(_ password : UITextField){
        self.wrongpass.alpha = 0
    }
}
