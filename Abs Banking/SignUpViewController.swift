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
  //  let ip = "localhost:9595"
    
    let datePickerView : UIDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        chooseDate()
        // Do any additional setup after loading the view.
    }

    @IBAction func registerUser(_ sender: Any) {
        

        let firstNameText = firstName.text!
        let lastNameText = lastName.text!
        let phoneText = phone.text!
        let dobText = dob.text!
        let aadharNumberText = aadharNumber.text!
        let panNumberText = panNumber.text!
        let zipCodeText = zipCode.text!
        let passwordText = password.text!
        

        
        let signUpQuery = URL(string: "http://\(ip)/details/insert?aadhar=\(aadharNumberText)&pan=\(panNumberText)&f_name=\(firstNameText)&l_name=\(lastNameText)&phone=\(phoneText)&dob=\(dobText)&zip=\(zipCodeText)&passwd=\(passwordText)")
        

        let newdevice = self.storyboard?.instantiateViewController(withIdentifier: "NewDeviceVerificationViewController") as! NewDeviceVerificationViewController
        newdevice.mobileNumber = Int(phoneText)
        newdevice.password = passwordText
        newdevice.isThisForSignUp = true
        newdevice.signUpUrl = signUpQuery
        self.navigationController?.pushViewController(newdevice, animated: true)
    }
    
    
     func chooseDate() {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponent = DateComponents()
        dateComponent.year = -18
        let maxDate = calendar.date(byAdding: dateComponent, to: Date())
        datePickerView.maximumDate = maxDate
        datePickerView.datePickerMode = .date
        dob.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    // Make a dateFormatter in which format you would like to display the selected date in the textfield.
    @objc
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
                
        dob.text = dateFormatter.string(from: datePickerView.date)
        
    }

}
