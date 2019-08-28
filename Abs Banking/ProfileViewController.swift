//
//  DetailsViewController.swift
//  Details Project
//
//  Created by apple on 24/08/19.
//  Copyright © 2019 DBS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseStorage
import Kingfisher


class ProfileViewController : UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var zipOutlet: UILabel!
    @IBOutlet weak var dobOutlet: UILabel!
    @IBOutlet weak var aadharOutlet: UILabel!
    @IBOutlet weak var pannoOutlet: UILabel!
    @IBOutlet weak var phnoOutlet: UILabel!
    @IBOutlet weak var bankidOutlet: UILabel!
    @IBOutlet weak var accnoOutlet: UILabel!
    @IBOutlet weak var fullnameOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    var accNumber : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        imageIndicator.sizeThatFits(CGSize.init(width: 30.0, height: 30.0))
        imageIndicator.color = UIColor.white
        
        if NetworkHelper.isConnectedToNetwork(){
            
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
           
            self.imageIndicator.alpha=1
            self.imageIndicator.startAnimating()
            
            self.imageOutlet.image = UIImage(named: "profile")

            self.imageOutlet.layer.cornerRadius = self.imageOutlet.frame.width/2
            
            AF.request("http://\(ip)/details/personal?acc_no=\(self.accNumber!)").response(completionHandler: { (response) in
                
                let jsonData = JSON(response.data as Any)
                print(jsonData)
                
                var imageUrl = jsonData["image_url"].stringValue
                imageUrl = imageUrl.replacingOccurrences(of: "@$", with: "&")
                imageUrl = imageUrl.replacingOccurrences(of: "@", with: "%2F")
                
                self.imageOutlet.kf.setImage(with: URL(string: imageUrl),
                                             placeholder: UIImage(named: "progress"))
            
                self.imageIndicator.stopAnimating()
                self.imageIndicator.alpha=0
                
                
                self.zipOutlet.text = jsonData["zip"].stringValue
                
                self.dobOutlet.text = jsonData["date"].stringValue
                
                self.aadharOutlet.text = jsonData["aadhar"].stringValue
                
                self.pannoOutlet.text = jsonData["pan_no"].stringValue
                
                self.phnoOutlet.text = jsonData["phone"].stringValue
                
                self.bankidOutlet.text = jsonData["bank_id"].stringValue
                
                self.accnoOutlet.text = jsonData["acc_no"].stringValue
                
                self.fullnameOutlet.text = jsonData["full_name"].stringValue
                
            })
        }
        else{
            print("no internet connection")
            checkInternet(self)
            self.imageIndicator.alpha=0
            self.imageIndicator.stopAnimating()
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOutlet.image=info[.originalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
        let alert = UIAlertController(title: "Save the image ?", message: "Do you want to save the image to the profile?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "save", style: .default, handler: { _ in
            self.uploadImage()
            self.imageIndicator.alpha=1
            self.imageIndicator.startAnimating()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func changeDpAction(_ sender: Any) {
        checkInternet(self)
        let myPickerView = UIImagePickerController()
        myPickerView.delegate = self;
        myPickerView.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerView, animated: true, completion: nil)
        
    }
    
    func uploadImage(){
        
        if NetworkHelper.isConnectedToNetwork(){
            
            self.imageIndicator.alpha=1
            self.imageIndicator.startAnimating()
            
            let storage = Storage.storage()
            var data = Data()
            data = (self.imageOutlet.image!.pngData())!;
            let storageRef = storage.reference()
            
            var imagenameurl="images/"+accnoOutlet.text!+".png"
            
            let imageRef=storageRef.child(imagenameurl)
            
            imageRef.putData(data,metadata: nil,completion: { (metadata,error) in
               
                guard let metadata = metadata else{
                    print("error in storing firebase  \(error!)")
                    self.imageIndicator.alpha=0
                    self.imageIndicator.stopAnimating()
                    return
                }
                
                print("balh blah \(metadata.path!)")
                
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
                    
AF.request("http://\(ip)/details/setImage?acc_no=\(self.accNumber!)&image_url=\(stringUrl!)")
                        .validate()
                    
                    self.imageIndicator.alpha=0
                    self.imageIndicator.stopAnimating()
                    
                    
                })
                
   
                
            })
        }
        else{
            print("No internet connection")
            checkInternet(self)
        }
        
        
        
    }
    
    
    @IBAction func logout(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LoginViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        
        }
    }
    
}
