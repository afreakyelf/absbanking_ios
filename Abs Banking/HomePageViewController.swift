//
//  HomePageViewController.swift
//  Abs Banking
//
//  Created by apple on 20/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var welcomeText: UILabel!
    var accNumber : Int? = 0
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var fdButton: UIButton!
    @IBOutlet weak var loanButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Do any additional setup after loading the view.
        
        if defaults.integer(forKey: "accountNo") != nil
        {
            accNumber = defaults.integer(forKey: "accountNo")
           self.welcomeText.text = "Welcome \(accNumber!)"
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    self.navigationItem.title = nil              //To make the back button text nil
  
        if segue.identifier == "walletSegue" {
            let S = segue.destination as! WalletViewController
            S.accNumber = accNumber!
        }
            
        else if segue.identifier == "loanSegue" {
            let S = segue.destination as! LoanViewController
            S.accNumber = accNumber!
        }
     
        else if segue.identifier == "fixedDepositSegue" {
            let S = segue.destination as! FixedDepositViewController
            S.accNumber = accNumber!

        }
        
    }
 
    

    
}
