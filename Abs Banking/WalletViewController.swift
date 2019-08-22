//
//  WalletViewController.swift
//  Abs Banking
//
//  Created by apple on 18/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WalletViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var accNumber : Int? = 0
    var accBal : Int? = 0
    var transactionArray = [[String:AnyObject]]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remainingBalance: UILabel!
    
    let ip = "localhost:9595"
    //  let ip = "172.20.2.79:9696"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendMoneySegue"{
            let seg = segue.destination as! SendMoneyViewController
            seg.accNumber = self.accNumber
            seg.accBalance = self.accBal
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "transactionCell")

        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        loadBalance();
        
        loadTransactions();
        
        self.tableView.tableFooterView = UIView()

        self.tableView.reloadData()
        
    }
    
    func loadBalance(){
        
        let url = URL(string: "http://\(ip)/details/balanceOf?acc_no=\(accNumber!)")
        
        AF.request(url!).responseJSON{ (responseData) -> Void in
            print(responseData)
            let swiftJsonVar = JSON(responseData.data as Any)
            let bal = swiftJsonVar["balance"].stringValue
            self.remainingBalance.text = bal
            self.accBal = Int(bal)
            
        }
        
    }
    
    func loadTransactions(){
        let url = URL(string: "http://\(ip)/transactions/findAcc?account=\(accNumber!)")
        
        AF.request(url!).responseJSON {
            (responseData) -> Void in
              let jsonData = JSON(responseData.data as Any)
            if let resData = jsonData["list"].arrayObject{
                self.transactionArray = resData as! [[String:AnyObject]]
            }
            
            if(self.transactionArray.count>0){
                self.tableView.reloadData()
            }

        }
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.transactionArray.count)
        return self.transactionArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        cell = UITableViewCell(style:.subtitle, reuseIdentifier: "transactionCell")

        
        var dict = transactionArray[indexPath.row]
        print(dict["amount"]!)
        
        if(dict["toAcc"]! as? Int == accNumber!){
            cell.textLabel?.text = "Received From \(dict["fromAcc"]!)"
            cell.detailTextLabel?.text = "+\(dict["amount"]!)"
        }else{
            cell.textLabel?.text = "Sent To \(dict["toAcc"]!)"
            cell.detailTextLabel?.text = "-\(dict["amount"]!)"
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var dict = transactionArray[indexPath.row]
        
        let id = dict["id"]
        let fromAcc = dict["fromAcc"]
        let toAcc = dict["toAcc"]
        let amount = dict["amount"]
        let date = dict["date"]
        
        let result = "id: \(id!) \nFrom Account: \(fromAcc!)\nTo Account: \(toAcc!)\nAmount: \(amount!) \nDate: \(date!)"
        
        let alertController = UIAlertController(title: "Transaction Details ", message: result, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss" , style: .default ))
        
        self.present(alertController,animated: true,completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = "Wallet"
        self.loadBalance()
        self.loadTransactions()
    }
 
    
}
