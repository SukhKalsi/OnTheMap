//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 15/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    // Properties
    let errorBorderColor: UIColor = UIColor( red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0 )
    
    // Outlets
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var preloader: UIActivityIndicatorView!
    @IBOutlet var loginView: UIView!
    
    // Actions
    @IBAction func btnLogin(sender: UIButton) {
        
        // remove any previous errors applied to the text fields
        resetTextfieldErrors(textfieldEmail)
        resetTextfieldErrors(textfieldPassword)
        
        if textfieldEmail.text!.isEmpty && textfieldPassword.text!.isEmpty {
            animateView()
            showTextfieldError(textfieldEmail)
            showTextfieldError(textfieldPassword)
            showAlert("", message: "Please enter your email and password")
        } else if textfieldEmail.text!.isEmpty {
            animateView()
            showTextfieldError(textfieldEmail)
            showAlert("", message: "Please enter your email")
        } else if textfieldPassword.text!.isEmpty {
            animateView()
            showTextfieldError(textfieldPassword)
            showAlert("", message: "Please enter your password")
        } else {
            
            enableForm(false)
            
            UdacityClient.sharedInstance().authenticateUser(textfieldEmail.text!, password: textfieldPassword.text!) { (success, error) in
                
                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.enableForm(true)
                        self.animateView()
                        self.showAlert("Login failure", message: error!)
                    }
                }
            }
        }
    }
    
    // View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableForm(true)
    }
    
    // Custom view controller functions
    
    // Solution taken and modified from Stackoverflow: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func animateView() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(loginView.center.x - 10, loginView.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(loginView.center.x + 10, loginView.center.y))
        loginView.layer.addAnimation(animation, forKey: "position")
    }
    
    // Not the prettiest solution, but shows user what textfield is issue.
    func showTextfieldError(textfield: UITextField) {
        textfield.layer.borderColor = errorBorderColor.CGColor
        textfield.layer.borderWidth = 2.0
    }
    
    func resetTextfieldErrors(textfield: UITextField) {
        textfield.layer.borderColor = nil
        textfield.layer.borderWidth = 0.0
    }
    
    func enableForm(enabled: Bool) {
        textfieldEmail.enabled = enabled
        textfieldPassword.enabled = enabled
        btnLoginOutlet.enabled = enabled
        
        if enabled {
            preloader.alpha = 0.0
            preloader.stopAnimating()
        } else {
            preloader.alpha = 1.0
            preloader.startAnimating()
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.enableForm(true)
            self.performSegueWithIdentifier("showTabs", sender: self)
        })
    }
}
