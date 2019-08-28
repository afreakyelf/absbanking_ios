//
//  UIProperties.swift
//  Abs Banking
//
//  Created by apple on 28/08/19.
//  Copyright © 2019 Rajat. All rights reserved.
//

import Foundation

import UIKit

extension UIButton
{
    func buttonProperties(){
        self.layer.cornerRadius = 10.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.5
        self.layer.backgroundColor = UIColor(displayP3Red: 68/255.0, green: 180/255.0, blue: 248/255.0, alpha: 1.0).cgColor
    }
}

extension UIView
{
    func borderProperties(){
        
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.gray.cgColor
    }
    func cornerRadius(){
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 20.0
        self.layer.borderColor = UIColor(displayP3Red: 68/255.0, green: 180/255.0, blue: 248/255.0, alpha: 1.0).cgColor
        
    }
    
    func cardProperties(){
        
        self.layer.cornerRadius = 20.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.5
        
    }
}

