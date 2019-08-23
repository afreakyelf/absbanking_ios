//
//  FixedDepositViewController.swift
//  Abs Banking
//
//  Created by Apple on 22/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FixedDepositViewController: UIViewController {

    
    var array = [[String:AnyObject]]()
    
    var accNumber : Int? = 8
    
    @IBOutlet weak var totalfdlabel: UILabel!
    @IBOutlet weak var DepositTextEdit: UITextField!
    
    @IBOutlet weak var CurrentDepositeLable: UILabel!
    
    @IBOutlet weak var fixedbt: UIButton!
    @IBOutlet weak var DisplaySliderValue: UILabel!
    
    @IBOutlet weak var CalculatedDepositeValue: UILabel!
    @IBOutlet weak var SliderOutlet: UISlider!
    
    let FixeddepositValue : Int = 0
    var years : Int = 0
    let amountToCalculate : Int = 0
    let r : Double = 7.00
   // let ip = "172.20.3.109:9696"
     let ip = "localhost:9595"
    
    
    override func viewDidLoad() {
        loadFixedDeposit()
    }
    
    @IBAction func DepositButton(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Make a fixed Deposit", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the amount"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter the Duration in Years"
        }
        
        let saveAction = UIAlertAction(title: "New Fixed Deposit", style: UIAlertAction.Style.default, handler: { alert -> Void in
            self.CurrentDepositeLable.text=alertController.textFields![0].text
            let newMonthLoanValue = alertController.textFields![1].text
            let date=Date();
            let formatter=DateFormatter();
            formatter.dateFormat="dd.MM.yyyy"
            let result1=formatter.string(from: date)
            print(result1)
            
            let url = URL(string: "http://\(self.ip)/fixed/insertfd?acc_no=\(self.accNumber!)&amount=\(alertController.textFields![0].text!)&dod=\(result1)&duration=\(newMonthLoanValue!)")
            
            AF.request(url!).validate();
            
            self.loadFixedDeposit()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    func showAlert() {
        let alert = UIAlertController(title: "Please Enter the Amount Value", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func SliderDepositAction(_ sender: UISlider) {
        
        years = Int(SliderOutlet.value)
        DisplaySliderValue.text = String(years)
        
    }
    
    func cal(_ amount: Int,_ years :Int) -> String{
        let powerfd: Double = pow(1+(r/100),Double(years))
        let finalfd: Double = Double(amount) * powerfd
        return "Total Amount : ₹ "+String(format : "%.2f",finalfd);
    }
    
    @IBAction func CalculateDepositeBtn(_ sender: Any) {
        if(!(DepositTextEdit.text!.isEmpty))
        {
            years = Int(SliderOutlet.value)
            let amountToCalculate = Int(DepositTextEdit.text!)
            CalculatedDepositeValue.text = cal(amountToCalculate!, years)
        }
        else{
            self.showAlert()
        }
    }
    
    
    func loadFixedDeposit(){
        
        let url = URL(string: "http://\(ip)/fixed/getallfdbyid/?acc_no=\(accNumber!)")
        
        AF.request(url!).responseJSON { (response) -> Void in
            let jsonData = JSON(response.data as Any)
            if jsonData.isEmpty {
                self.fixedbt.isHidden=false
                self.totalfdlabel.isHidden=true
            }else{
                let amount = jsonData["amount"].rawValue
                print(amount)
                let yr=jsonData["duration"].rawValue
                self.CurrentDepositeLable.text = "\(amount)"
                self.fixedbt.isHidden=true
                self.totalfdlabel.isHidden=false
                self.totalfdlabel.text=self.cal(amount as! Int,yr as! Int)
            }
            
        }
        
    }
    
}


