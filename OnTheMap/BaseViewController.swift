//
//  BaseViewController.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 14/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // Generic Alert
    func showAlert(title: String, message: String) {
        
        // Create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create singular OK action - there is only one option to dismiss.
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        // Add the action
        alert.addAction(action)
        
        // Display the alert to current view controller
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Existing Post overwrite alert, used by Information Posting view.
    func showExistingPostAlert() {
        
        // Create the alert controller
        let alert = UIAlertController(title: "", message: "You have already posted a Student Location. Would you like to overwrite this with your current location?", preferredStyle: .Alert)
        
        // Create the overwrite action
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default) { UIAlertAction in
            // update the flag so we know we are overwriting
            OTMAccount.updateInformationPosting = true
        }
        
        // Create the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { UIAlertAction in
            // just incase this has be made to true (it hasn't yet but could be by another developer!), set this to false again.
            OTMAccount.updateInformationPosting = false
        }
        
        // Add the actions
        alert.addAction(overwriteAction)
        alert.addAction(cancelAction)
        
        // Display the alert to current view controller
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}

