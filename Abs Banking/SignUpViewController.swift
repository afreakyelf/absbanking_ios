//
//  SignUpViewController.swift
//  Abs Banking
//
//  Created by apple on 18/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var aadharNumber: UITextField!
    @IBOutlet weak var panNumber: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var password: UITextField!
    
   // let ip = "172.20.2.79:9696"
    let ip = "localhost:9595"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func registerUser(_ sender: Any) {
        
        let defaults = UserDefaults.standard

        
        let firstNameText = firstName.text!
        let lastNameText = lastName.text!
        let phoneText = phone.text!
        let dobText = dob.text!
        let aadharNumberText = aadharNumber.text!
        let panNumberText = panNumber.text!
        let zipCodeText = zipCode.text!
        let passwordText = password.text!
        
        
        
        let signUpQuery = URL(string: "http://\(ip)/details/insert?aadhar=\(aadharNumberText)&pan=\(panNumberText)&f_name=\(firstNameText)&l_name=\(lastNameText)&phone=\(phoneText)&dob=\(dobText)&zip=\(zipCodeText)&passwd=\(passwordText)")
        
        AF.request(signUpQuery!).validate()
        
        let alertController = UIAlertController(title: "Alert", message: "User Registered!", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss" , style: .default))
        
        self.present(alertController,animated: true,completion: nil)
        
        defaults.set(passwordText, forKey: phoneText)
        
    }

}
