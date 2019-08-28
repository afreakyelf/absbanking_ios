//
//  ForgotPasswordViewController.swift
//  Abs Banking
//
//  Created by apple on 21/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    var otpVerified : Bool?
    var phoneNumber : Int?
    
    
    @IBOutlet weak var wrongOtp: UILabel!
    @IBOutlet weak var otpSendtoLabel: UILabel!
    @IBOutlet weak var enterTheOtpLabel: UILabel!
    @IBOutlet weak var submitOtpBtn: UIButton!
    
    @IBOutlet weak var otptextField: UITextField!
    @IBOutlet weak var mobileNumber: UILabel!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var newRePassword: UITextField!
    
    @IBOutlet weak var createBtn: UIButton!
    
    override func viewDidLoad() {
        
        checkInternet(self)
        
        [otptextField,newRePassword,newPassword,userId].forEach {
            setPadding($0)
        }
        
        super.viewDidLoad()
        otptextField.delegate = self
        newPassword.delegate = self
        newRePassword.delegate = self
        otptextField.textContentType = .oneTimeCode
        self.userId.delegate = self
        
        self.newRePassword.addTarget(self, action: #selector(newRePwd), for: .editingChanged)
        
    }
    


    @IBAction func sendOtp(_ sender: Any) {
        
        checkInternet(self)

        
        let userName = Int(self.userId.text!)
        
        if userName == nil {
            return
        }
        
        let url = "http://\(ip)/details/checkRegister?acc_no=\(userName!)"
        print(url)
        
        AF.request(url).responseJSON {
            (responseData) -> Void in
            let jsonData = JSON(responseData.data as Any)
            self.phoneNumber = jsonData["phone"].intValue
            print(self.phoneNumber!)
            self.sendOTPFunction(self.phoneNumber!)
         
            [self.otpSendtoLabel, self.enterTheOtpLabel, self.mobileNumber, self.otptextField , self.submitOtpBtn].forEach {
                $0?.alpha = 1
            }
            
        }
        
    }
    
    func sendOTPFunction(_ phone : Int){
        
        self.mobileNumber.text = "\(phone)"
        
        let phoneNumber = "+91\(phone)"
        print("otp send to \(phoneNumber)")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
            Auth.auth().languageCode = "en";
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
        
    }
    
    @IBAction func verify(_ sender: Any) {
        
        checkInternet(self)
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        print(verificationID!)
        
        let opt = self.otptextField.text
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "",
                                                                 verificationCode: opt!)
        Auth.auth().signIn(with: credential) { authData, error in
            if ((error) != nil) {
                // Handles error
                print("Error")
                self.wrongOtp.alpha = 1
                return
            }
            print("Success")
            self.wrongOtp.alpha = 0
            self.newPassword.alpha = 1
            self.newRePassword.alpha = 1
            self.createBtn.alpha = 1
            self.otpVerified = true
            
        }
        
    }
    
    @IBAction func createPassword(_ sender: Any) {
        
        checkInternet(self)

        
        let newpwd = self.newPassword.text!
        let newRepwd = self.newRePassword.text!
        
        if(newpwd != newRepwd){
            self.wrongOtp.text = "Passwords are not matching"
            self.wrongOtp.alpha = 1
            return
        }
        
        UserDefaults.standard.set(newRepwd, forKey: "\(self.phoneNumber!)")

        let url = URL(string: "http://\(ip)/details/updatePasswd?acc_no=\(self.userId.text!)&passwd=\(newRepwd)")

        AF.request(url!).validate()
        
        print("password of \(UserDefaults.standard.string(forKey: "\(self.phoneNumber!)")!) is \(newRepwd)")
        
        let alertController = UIAlertController(title: "Alert", message: "Password Reset Done! Please Login again", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title:"Dismiss", style: .default, handler:  { action in self.navigationController?.popViewController(animated: true)}))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc
    func newRePwd(_ textField : UITextField) {
        self.wrongOtp.alpha = 0
    }
    
}
