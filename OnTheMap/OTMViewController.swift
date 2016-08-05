//
//  OTMViewController.swift
//  OnTheMap
//  UITabViewController which is shares same functionaility on Map and List view controllers
//
//  Created by Sukh Kalsi on 16/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit

class OTMViewController: UITabBarController {
    
    @IBAction func btnLogout(sender: UIBarButtonItem) {
        UdacityClient.sharedInstance().endSession() { success, error in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func btnInformationPosting(sender: UIBarButtonItem) {
        performSegueWithIdentifier("showInformationPosting", sender: self)
    }
    
    @IBAction func btnRefresh(sender: UIBarButtonItem) {
        // fire off notification that we want to refresh
        let notification = NSNotification(name: ParseClient.Constants.NotificationID, object: self)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}
