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

var timer = Timer()
func inactive(viewController : UIViewController){
    timer = Timer.scheduledTimer(timeInterval: 180, target: viewController, selector: #selector(WalletViewController.doStuff), userInfo: nil, repeats: true)
    let resetTimer = UITapGestureRecognizer(target: viewController, action: #selector(WalletViewController.resetTimer));
    viewController.view.isUserInteractionEnabled=true
    viewController.view.addGestureRecognizer(resetTimer)
}

class WalletViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var accNumber : Int? = 0
    var accBal : Int? = 0
    var transactionArray = [[String:AnyObject]]()
    var refreshControl = UIRefreshControl()


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remainingBalance: UILabel!
    
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

        checkInternet(self)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        loadBalance();
        
        loadTransactions();
        
        self.tableView.tableFooterView = UIView()

        self.tableView.reloadData()
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for:.valueChanged)
        tableView.addSubview(refreshControl)

        inactive(viewController : self)

    }
    
    @objc func pullToRefresh(){
        print("refreshing")
        checkInternet(self)
        loadBalance()
        refreshControl.endRefreshing()
        loadTransactions();
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!
            TableViewCell
        
        var dict = transactionArray[indexPath.row]
        
        if(dict["toAcc"]! as? Int == accNumber!){
            cell.textL?.text = "Received From"
            cell.accLabel?.text = "\(dict["fromAcc"]!)"
            cell.valueLabel?.text = "\(dict["amount"]!)"
            cell.valueLabel?.textColor = UIColor.green
            cell.imageOutlet.image = UIImage(named: "receive.png")
            cell.dateLabel.text = "\(dict["date"]!)"
            
        }else{
            cell.valueLabel?.textColor = UIColor.red
            cell.textL?.text = "Sent To"
            cell.accLabel?.text = "\(dict["toAcc"]!)"
            cell.valueLabel?.text = "\(dict["amount"]!)"
            cell.imageOutlet.image = UIImage(named: "sent.png")
            cell.dateLabel.text = "\(dict["date"]!)"
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = "Wallet"
        self.loadBalance()
        self.loadTransactions()
    }
    
    @objc func doStuff() {
        // perform any action you wish to
        let alertController = UIAlertController(title: "Session TimeOut", message: "your session has been time out \n please login again", preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
            print("User has been inactive for more than 3 Minutes.")
          
            let newdevice = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(newdevice, animated: true)
            
            timer.invalidate()
            
        })
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func resetTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(WalletViewController.doStuff), userInfo: nil, repeats: true)
    }
    
    
    
}

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var accLabel: UILabel!
    @IBOutlet weak var tableviewcell: UIView!
    @IBOutlet weak var textL: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}

