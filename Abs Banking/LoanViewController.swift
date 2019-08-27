//
//  LoanViewController.swift
//  Abs Banking
//
//  Created by apple on 20/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseStorage

class LoanViewController: UIViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    var name:String=""
    
    var accNumber : Int? = 0

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Loan"
    }
    
    
    @IBOutlet weak var panUploaded: UILabel!
    @IBOutlet weak var panProgress: UIActivityIndicatorView!
    @IBOutlet weak var aadharProgress: UIActivityIndicatorView!
    @IBOutlet weak var aadharUploaded: UILabel!
    @IBOutlet weak var uploadPanBtn: UIButton!
    @IBOutlet weak var uploadAadharBtn: UIButton!
    @IBOutlet weak var emi: UILabel!
    @IBOutlet weak var CurrentLoanLable: UILabel!
    @IBOutlet weak var DisplayCalculatedLoan: UILabel!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var LoanSlider: UISlider!
    @IBOutlet weak var DisplaySliderValue: UILabel!
    @IBOutlet weak var newloanoulet: UIButton!
    
    var isAadharUploaded : Bool? = false
    var isPanUploaded : Bool? = false
    
    let monthString :Int = 0
    let currentLoanvalue:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternet(self)
        loadLoan()
        checkForDocuments()
        
        panProgress.style = UIActivityIndicatorView.Style.whiteLarge
        
        panProgress.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
    
        panProgress.color = UIColor.white
        
        aadharProgress.style = UIActivityIndicatorView.Style.whiteLarge
        
        aadharProgress.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
        
        aadharProgress.color = UIColor.white
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Please Enter the Amount Value", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func emiCal(_ pAmount:Double, _ monthString : Int) -> String{
        let interest: Double = 7/12/100
        let quotient: Double = (pAmount*interest)
        let powerLoan : Double = pow((1+interest),Double(monthString))
        let finalEmi = (quotient*powerLoan)/(powerLoan-1)
        let totalamount = (Double(finalEmi)*Double(monthString))
        let tamount = "EMI : ₹ "+String(format : "%.2f",finalEmi)+" | Total Amount : ₹ "+String(format : "%.2f",Double(totalamount))
        return tamount
    }
    
    
    @IBAction func calculateLoanBtn(_ sender: Any) {
        
        if(!(AmountTextField.text!.isEmpty)){
            
            let pAmount = AmountTextField.text
            let pAmount1 = NSString(string: pAmount!).doubleValue
            let monthString = Int(LoanSlider.value)
         
            DisplayCalculatedLoan.text = emiCal(pAmount1,monthString)
        }
        else
        {
            self.showAlert()
        }
        
    }
    
    @IBAction func SliderOutletAction(_ sender: UISlider) {
        
        let monthString = LoanSlider.value
        DisplaySliderValue.text = String(Int(monthString))
        
    }
    
    
    
    @IBAction func NewLoneActionBtn(_ sender: Any) {
        
        checkInternet(self)

        
        let pleaseAlert = UIAlertController(title: "Alert", message: "Please Upload Mandatory Documents", preferredStyle: .alert)
        pleaseAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        if !(self.isPanUploaded! == true && self.isAadharUploaded! == true){
            let pleaseAlert = UIAlertController(title: "Alert", message: "Please Upload Mandatory Documents", preferredStyle: .alert)
            pleaseAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(pleaseAlert,animated: true,completion: nil)
            return
        }
        
        let alertController = UIAlertController(title: "Get A New Loan", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the amount"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the Duration in months"
        }
        let saveAction = UIAlertAction(title: "Get Loan", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let date=Date();
            let formatter=DateFormatter();
            formatter.dateFormat="dd.MM.yyyy"
            let result1=formatter.string(from: date)
            print(result1)
            let newMonthLoanValue = alertController.textFields![1].text
            print(alertController.textFields![0].text!)
            print(newMonthLoanValue!)
            
            //var newloanoulet.alpha=0
            let url = URL(string: "http://\(ip)/loan/insertloan/?accNum=\(self.accNumber!)&amount=\(alertController.textFields![0].text!)&dol=\(result1)&duration=\(newMonthLoanValue!)")
            //   print(url ?? <#default value#>);
            AF.request(url!).validate();
            
            self.loadLoan()
            
            
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func loadLoan(){
        
        AF.request("http://\(ip)/loan/getallloanbyid/?acc_num=\(self.accNumber!)").responseJSON { response in
            let jsonData = JSON(response.data as Any)
            print(jsonData)
            
            if jsonData.isEmpty {
                self.newloanoulet.isHidden=false
                self.emi.isHidden=true
            }else{
                let amount = jsonData["amount"].doubleValue
                print(amount)
                let months = jsonData["duration"].intValue
                self.CurrentLoanLable.text = "\(amount)"
                self.newloanoulet.isHidden = true
                self.emi.isHidden=false
                self.emi.text=self.emiCal(amount, months )
            }
            
        }
        
    }
    
    
    @IBAction func UploadAadhar(_ sender: UIButton) {
        
        checkInternet(self)

        
        print("in aadhar")
        name="aadhar"
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        animate(name, 1)
    }
    
    
    @IBAction func UploadPan(_ sender: UIButton) {
        
        checkInternet(self)
        
        print("in pan")
        name="pan"
        // imageUpload()
        let myPickerController = UIImagePickerController()
        print(myPickerController)
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
        print("after")
        animate(name, 1)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // imageview.image = info[.originalImage] as? UIImage
        let image=info[.originalImage] as! UIImage;
        //self.dismiss(animated: true, completion: nil)
        //imageview.image=image
        self.dismiss(animated: true, completion: nil)
        let storage = Storage.storage()
        var data = Data()
        data = (image.pngData())!;
        let storageRef = storage.reference()
        print(storageRef)
        let imagenameurl="images/\(accNumber!)/"+self.name+".png"
        //var imagenameurl="images/sec.png"
        
        let imageRef=storageRef.child(imagenameurl)
        
        imageRef.putData(data,metadata: nil,completion: { (metadata,error) in
            guard metadata != nil else{
                print(error as Any)
                return
            }
            
            
            imageRef.downloadURL(completion: { (url, err) in
                
                if let err = err {
                    print("Error downloading image file, \(err.localizedDescription)")
                    return
                }
                
                guard let url = url else { print("no url") ; return }
                
                var stringUrl : String?
                
                print(url)
                stringUrl = url.absoluteString.replacingOccurrences(of: "&", with: "@$")
                stringUrl = stringUrl!.replacingOccurrences(of: "%2F", with: "@")
                
                print(stringUrl!)
                
                let urlToFetch = URL(string: "http://\(ip)/details/set\(self.name)Image?acc_no=\(self.accNumber!)&\(self.name)_url=\(stringUrl!)")
                
                print(urlToFetch!)
                
                AF.request(urlToFetch!).validate();
                
                self.hideButton(which: self.name, hide: true)
                
                self.animate(self.name, 0)
                
                if self.name == "aadhar"{
                    self.isAadharUploaded = true
                }else if self.name == "pan" {
                    self.isPanUploaded = true
                }
                
            })
            
        })
        
        print("image url \(imagenameurl)")
       
        
    }
    
    func hideButton( which : String , hide : Bool){
        if which == "aadhar" {
            if hide {
              self.uploadAadharBtn.alpha = 0
              self.aadharUploaded.alpha = 1
            }else{
              self.uploadAadharBtn.alpha = 1
                self.aadharUploaded.alpha = 0

            }
        }else{
            if hide {
                self.uploadPanBtn.alpha = 0
                self.panUploaded.alpha = 1

            }else{
                self.uploadPanBtn.alpha = 1
                self.panUploaded.alpha = 0
            }
        }
            
    }
    
    func checkForDocuments(){
        
        let urlToFetchForAadhar = URL(string: "http://\(ip)/details/getaadharImage?acc_no=\(self.accNumber!)")
        
        AF.request(urlToFetchForAadhar!).responseJSON { response in
            let jsonData = JSON(response.data as Any)
            print(jsonData)
            
            if jsonData.isEmpty {
              self.hideButton(which: "aadhar", hide: false)
            }else{
                let aadhar_no = jsonData["aadhar"].stringValue
                let aadhar_url = jsonData["aadhar_url"].stringValue
                if aadhar_no == "" {
                    self.hideButton(which: "aadhar", hide: false)
                }else{
                    if aadhar_url != "" {
                        self.hideButton(which: "aadhar", hide: true)
                        self.isAadharUploaded = true
                    }else{
                        self.hideButton(which: "aadhar", hide: false)
                    }
                }
            }
            
        }
        
        
        let urlToFetchForPan = URL(string: "http://\(ip)/details/getpanImage?acc_no=\(self.accNumber!)")
        
        AF.request(urlToFetchForPan!).responseJSON { response in
            let jsonData = JSON(response.data as Any)
            print(jsonData)
            
            if jsonData.isEmpty {
                self.hideButton(which: "pan", hide: false)
            }else{
                let aadhar_no = jsonData["pan_no"].stringValue
                let aadhar_url = jsonData["pan_url"].stringValue
                if aadhar_no == "" {
                    self.hideButton(which: "pan", hide: false)
                }else{
                    if aadhar_url != "" {
                        self.hideButton(which: "pan", hide: true)
                        self.isPanUploaded = true
                    }else{
                        self.hideButton(which: "pan", hide: false)
                    }
                }
            }
            
        }
        
    }
    
    func animate(_ what:String ,_ int : Int){
        if what == "aadhar" {
            self.aadharProgress.alpha = CGFloat(int)
            if int == 1 {
                self.aadharProgress.startAnimating()
            }else{
                self.aadharProgress.stopAnimating()
            }
        }else{
            self.panProgress.alpha = CGFloat(int)
            if int == 1 {
                self.panProgress.startAnimating()
            }else{
                self.panProgress.stopAnimating()
            }
        }
        
    }
    

    
}
