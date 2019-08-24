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

class LoginViewController: UIViewController,UITextFieldDelegate  {

    
    @IBOutlet weak var wrongpass: UILabel!
    @IBOutlet weak var userdnne: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    let ip = "localhost:9595"
//  let ip = "172.20.2.79:9696"

    @IBAction func blah(_ sender: Any) {
    }
    
    var mobileNumber = 0
    var pBool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        animate(1)
        loginButton.alpha = 0
        
        let userName = Int(self.userName.text!)
        
        if userName == nil {
            return
        }
        
        let url = "http://\(ip)/details/checkRegister?acc_no=\(userName!)"
        print(url)
        var trya : Bool?
        
        AF.request(url).responseJSON {
            (responseData) -> Void in
            let jsonData = JSON(responseData.data as Any)
            trya = jsonData["isExist"].boolValue
            print("####\(trya!)")
            self.mobileNumber = jsonData["phone"].intValue
            print(self.mobileNumber)
            
            let defaults = UserDefaults.standard
            
            if defaults.string(forKey: String(self.mobileNumber)) != nil {
                
                let passwordd = defaults.string(forKey: String(self.mobileNumber))!
                print(passwordd)
                
                if(passwordd == self.password!.text){
                    print("Success")
                    
                    //self.performSegue(withIdentifier: "loginSegue", sender: self)
                    
                    print(userName!)
                    UserDefaults.standard.set(userName!, forKey: "accountNo")
                
                    
                  //Navigating to another screen HomePageViewController
                    let homePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
                   
                    print("Sending value \(userName!)")
                    homePage.accNumber = userName!
                    self.navigationController?.pushViewController(homePage, animated: true)
                    
                    self.animate(0)
                    self.loginButton.alpha = 1
                    

                }else{
                    
                    print("Error Matching password")
                    self.checkPwdInDatabase(userName!,self.password.text!)
                    
                    self.animate(0)
                    self.loginButton.alpha = 1
                    
                }
            
            }else{
                print("Error")
                self.animate(0)
                self.loginButton.alpha = 1
                self.userdnne.alpha = 1
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.userName.delegate = self
        self.password.delegate = self
    }
    
    func checkPwdInDatabase(_ username: Int,_ pwd : String) {
        
        var password : String?
        let url = URL(string: "http://\(ip)/details/getPasswd?acc_no=\(username)")

        AF.request(url!).responseJSON {
            (responseData) -> Void in
            let jsonData = JSON(responseData.data as Any)
            password = jsonData["passwd"].stringValue
            print(password!)
            
            if(pwd == password!){
                
                print("we got it")
                
                let alertController = UIAlertController(title: "New Device Verification", message: "Please verify your device on next screen", preferredStyle: UIAlertController.Style.alert)
                
                let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
                    
                    let newdevice = self.storyboard?.instantiateViewController(withIdentifier: "NewDeviceVerificationViewController") as! NewDeviceVerificationViewController
                    newdevice.mobileNumber = self.mobileNumber
                    newdevice.password = password!
                    self.navigationController?.pushViewController(newdevice, animated: true)
                    
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                    (action : UIAlertAction!) -> Void in })
                
                alertController.addAction(saveAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                
            }else{
                
                print("Wrong Password")
                self.wrongpass.alpha = 1
            }
            
        }
        
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
