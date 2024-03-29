//
//  SignUpViewController.swift
//  Abs Banking
//
//  Created by apple on 18/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpindicator: UIActivityIndicatorView!
    @IBOutlet weak var mylabel: UILabel!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var aadharNumber: UITextField!
    @IBOutlet weak var panNumber: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    let datePickerView : UIDatePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        [firstName,lastName,phone,dob,aadharNumber,panNumber,zipCode,password].forEach {
            setPadding($0)
        }
        
        checkInternet(self)

        firstName.borderProperties()
        lastName.borderProperties()
        phone.borderProperties()
        dob.borderProperties()
        aadharNumber.borderProperties()
        panNumber.borderProperties()
        zipCode.borderProperties()
        password.borderProperties()
        
        
        signUpindicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        signUpindicator.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
        
        signUpindicator.color = UIColor.white
        
        chooseDate()
        // Do any additional setup after loading the view.
    }

    @IBAction func registerUser(_ sender: Any) {
        
        checkInternet(self)

        if checkUserInputs() {
            
            animate(1)
            
            let firstNameText = firstName.text!
            let lastNameText = lastName.text!
            let phoneText = phone.text!
            let dobText = dob.text!
            let aadharNumberText = aadharNumber.text!
            let panNumberText = panNumber.text!
            let zipCodeText = zipCode.text!
            let passwordText = password.text!
            
            let url = "http://\(ip)/details/insert?aadhar=\(aadharNumberText)&pan=\(panNumberText)&f_name=\(firstNameText)&l_name=\(lastNameText)&phone=\(phoneText)&dob=\(dobText)&zip=\(zipCodeText)&passwd=\(passwordText)"
            print(url)
            let signUpQuery = URL(string: url)
            print(signUpQuery!)
            
            let urlForCheckinguser = "http://\(ip)/details/checkRegister?acc_no=\(phoneText)"
            print(urlForCheckinguser)
            
            AF.request(URL(string: urlForCheckinguser)!).responseJSON {
                (responseData) -> Void in
                let jsonData = JSON(responseData.data as Any)
                let isExist = jsonData["isExist"].boolValue
                
                if isExist{
                    print("user already exists")
                    let alert = UIAlertController(title: "Alert!", message: "Number is already registered! Please try again with different Phone Number ", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.animate(0)
                }else{
                    let newdevice = self.storyboard?.instantiateViewController(withIdentifier: "NewDeviceVerificationViewController") as! NewDeviceVerificationViewController
                    newdevice.mobileNumber = Int(phoneText)
                    newdevice.password = passwordText
                    newdevice.isThisForSignUp = true
                    newdevice.signUpUrl = signUpQuery!
                    self.navigationController?.pushViewController(newdevice, animated: true)
                    self.animate(0)
                }
            }
        }

       
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
    
    func checkPhone(value: String) -> Bool {
        let PHONE_REGEX = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func checkAadhar(value: String) -> Bool {
        let PHONE_REGEX = "^[0-9]{12}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func checkPan(value: String) -> Bool {
        let PHONE_REGEX = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func checkPin(value: String) -> Bool {
        let PHONE_REGEX = "^[0-9]{6}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func checkUserInputs() -> Bool{
        
        if(checkPhone(value: self.phone.text!)){
            if(checkAadhar(value: self.aadharNumber.text!)){
                if(checkPan(value: self.panNumber.text!)){
                    if(checkPin(value: self.zipCode.text!)){
                        if(self.password.text!.count >= 8){
                            return true
                        } else{
                            mylabel.text = "Mimimum Password Length is 8"
                            return false
                        }
                    } else{
                        mylabel.text = "Invalid pincode"
                        return false
                    }
                    
                } else{
                    mylabel.text = "Invalid pan"
                    return false
                }
                
            } else{
                mylabel.text = "Invalid aadhar"
                return false
            }
            
        } else{
            mylabel.text = "Invalid mobile number"
            return false
        }
        
    }
    
    
    func animate(_ int : Int){
        self.signUpindicator.alpha = CGFloat(int)
        if(int==1){
            self.signUpindicator.startAnimating()
        }else{
            self.signUpindicator.stopAnimating()
        }
    }

}
