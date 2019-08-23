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

class LoanViewController: UIViewController {
    // var array = [[String:AnyObject]]()
    
    var accNumber : Int? = 0
    //let ip = "172.20.3.109:9696"
     let ip = "localhost:9595"
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Loan"
    }
    
    @IBOutlet weak var emi: UILabel!
    @IBOutlet weak var CurrentLoanLable: UILabel!
    @IBOutlet weak var DisplayCalculatedLoan: UILabel!
    @IBOutlet weak var AmountTextField: UITextField!
    @IBOutlet weak var LoanSlider: UISlider!
    @IBOutlet weak var DisplaySliderValue: UILabel!
    @IBOutlet weak var newloanoulet: UIButton!
    
    let monthString :Int = 0
    let currentLoanvalue:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLoan()
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
            //  let interest: Double = 7/12/100
            // let quotient: Double = (pAmount1*interest)
            // let powerLoan : Double = pow((1+interest),Double(monthString))
            // let finalEmi = (quotient*powerLoan)/(powerLoan-1)
            // let totalamount = (Int(finalEmi)*Int(monthString))
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
            let url = URL(string: "http://\(self.ip)/loan/insertloan/?accNum=\(self.accNumber!)&amount=\(alertController.textFields![0].text!)&dol=\(result1)&duration=\(newMonthLoanValue!)")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func loadLoan(){
        
        AF.request("http://\(self.ip)/loan/getallloanbyid/?acc_num=\(self.accNumber!)").responseJSON { response in
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
    
}
