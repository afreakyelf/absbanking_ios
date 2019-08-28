//
//  TransactionDoneViewController.swift
//  Abs Banking
//
//  Created by apple on 23/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit

class TransactionDoneViewController: UIViewController {
    
    
    var amountText : Int?
    var dateText : String?
    var toText : Int?
    var fromAcc : Int?
    var transactionId : Int?
    
    @IBOutlet weak var TransactionCardOutlet: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var toEmail: UILabel!
    @IBOutlet weak var to: UILabel!
    @IBOutlet weak var dismisOutlet: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismisOutlet.buttonProperties()
        TransactionCardOutlet.cardProperties()
        
        self.navigationItem.setHidesBackButton(true, animated: true)

        self.amount.text = "\(amountText!)"
        self.date.text = "\(stringToDate(dateText!,1))"
        self.to.text = "\(toText!)"
        self.time.text = "\(stringToDate(dateText!,0))"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func OK(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        //To pop to any view controller
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: WalletViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }

    }

    func stringToDate(_ date: String,_ timeOrDate : Int) -> String{

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: date)

        var date : String?
        if timeOrDate == 1{
          dateFormatter.dateFormat = "dd MMM yyyy"
            date = "\(dateFormatter.string(from: dateObj!))"
        }else{
            dateFormatter.dateFormat = "HH:mm:ss"
            date = "\(dateFormatter.string(from: dateObj!))"
        }
        
        return date!
        
    }


}
