//
//  NewDeviceVerificationViewController.swift
//  Abs Banking
//
//  Created by apple on 22/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire


class NewDeviceVerificationViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var wrongOtpLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var mobileNumber : Int?
    var password : String?
    var isThisForSignUp : Bool? = false
    var signUpUrl : URL!
    
    @IBOutlet weak var otpField: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        checkInternet(self)

        self.otpField.delegate = self
        
        self.sendOTPFunction(self.mobileNumber!)

        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        indicator.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
        
        indicator.color = UIColor.white
        
    }
    

    @IBAction func verifyOtp(_ sender: Any) {
        
        indicator.startAnimating()
        
        checkInternet(self)

        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        print(verificationID!)
        
        let opt = self.otpField.text
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "",verificationCode: opt!)
        
        Auth.auth().signIn(with: credential) { authData, error in
            if ((error) != nil) {
                // Handles error
                print("Error")
                self.indicator.stopAnimating()
                self.wrongOtpLabel.alpha = 1
                return
            }
            print("Success")
            
            UserDefaults.standard.set(self.password!, forKey: "\(self.mobileNumber!)")
            
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: LoginViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
            
            self.indicator.stopAnimating()
            
        }
        
        if isThisForSignUp!{
            print(self.signUpUrl!)
            AF.request(self.signUpUrl!).validate()
            indicator.stopAnimating()
        }
        
        
    }
    
    func sendOTPFunction(_ phone : Int){
        
        let phoneNumber = "+91\(phone)"
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
    
    
}
