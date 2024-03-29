//
//  SendMoneyViewController.swift
//  Abs Banking
//
//  Created by apple on 21/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class SendMoneyViewController: UIViewController, UITextFieldDelegate {

    var accNumber : Int? = 0
    var accBalance : Int? = 0
    var receiverAcc : Int? = 0
    
   // let ip = "localhost:9595"
    //  let ip = "172.20.2.79:9696"
    
    @IBOutlet weak var TransactionOutlet: UIButton!
    @IBOutlet weak var AmountLAble: UILabel!
    @IBOutlet weak var AmountTextOutlet: UITextField!
    @IBOutlet weak var searchBtnOutlet: UIButton!
    @IBOutlet weak var receiver: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var fromTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkInternet(self)

        // Do any additional setup after loading the view.
        self.AmountTextOutlet.delegate = self
        self.receiver.delegate = self
        self.noteTextView.alpha = 0
        
        fromTextLabel.text = "\(accNumber!)"
        
        
    }
    

    @IBAction func SearchBtnAction(_ sender: Any) {
        
        checkInternet(self)

        let receiverAccNumber = self.receiver.text
        
        if(Int(receiverAccNumber!) == accNumber){
            self.noteTextView.text = "Cannot send to Same account"
            self.noteTextView.alpha = 1
            return
        }
        
        let url = "http://\(ip)/details/checkRegister?acc_no=\(receiverAccNumber!)"
        
        AF.request(url).responseJSON {
            (responseData) -> Void in
            let jsonData = JSON(responseData.data as Any)
            let trya = jsonData["isExist"].boolValue
            print("####\(trya)")
            
            if trya {
                print("exist")
                self.AmountLAble.alpha = 1;
                self.AmountTextOutlet.alpha = 1;
                self.TransactionOutlet.alpha = 1;
                self.searchBtnOutlet.setTitle("Verfied!", for: .normal)
                self.searchBtnOutlet.tintColor = UIColor.green
                
                self.receiverAcc = Int(receiverAccNumber!)
                
            }else{
                print("nah")
                self.noteTextView.alpha = 1
                self.noteTextView.text = "User does not exist"
            }
            
        }
        
        receiver.addTarget(self, action: #selector(checkAccount), for: .editingChanged)

        
    }
    
    
    @IBAction func sendMoney(_ sender: Any) {
        
        checkInternet(self)

        
        let amount = Int(self.AmountTextOutlet.text!)!
        print(amount)
        
        if amount <= accBalance! {
            print("We have money")
            
            let url = URL(string: "http://\(ip)/transactions/makeTransaction?amount=\(amount)&from_acc=\(accNumber!)&to_acc=\(receiverAcc!)")
            
            AF.request(url!).responseJSON {
                (responseData) -> Void in
                let jsonData = JSON(responseData.data as Any)
                let id = jsonData["id"].intValue
                let fromAcc = jsonData["fromAcc"].intValue
                let toAcc = jsonData["toAcc"].intValue
                let amount = jsonData["amount"].intValue
                let date = jsonData["date"].stringValue
        
                
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myAlert = storyboard.instantiateViewController(withIdentifier: "TransactionDoneViewController") as! TransactionDoneViewController
                myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                myAlert.amountText = amount
                myAlert.dateText = date
                myAlert.toText = toAcc
                myAlert.fromAcc = fromAcc
                myAlert.transactionId = id
                self.navigationController?.pushViewController(myAlert, animated: true)
                
            }

            
            
        }else{
            print("Poor boy")
            self.noteTextView.alpha = 1
            self.noteTextView.text = "You don't have enough money"
        }
        
        self.AmountTextOutlet.addTarget(self, action: #selector(checkAmount), for: .editingChanged)

    }
    
    @objc
    func checkAccount(textfield: UITextField){
        self.noteTextView.alpha = 0
        self.AmountLAble.alpha = 0;
        self.AmountTextOutlet.alpha = 0;
        self.TransactionOutlet.alpha = 0;
        self.searchBtnOutlet.setTitle("Verify", for: .normal)
        self.searchBtnOutlet.tintColor = UIColor.blue
    }
    
    
    @objc
    func checkAmount(textfield: UITextField){
        self.noteTextView.alpha = 0
    }
    

    
}
