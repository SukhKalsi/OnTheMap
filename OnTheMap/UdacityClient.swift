//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 14/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation
import UIKit

// MARK: UdacityClient: NSObject

class UdacityClient : NSObject {
    
    var sessionID: String? = nil
    var userID: Int? = nil
    
    override init() {
        super.init()
    }
    
    func authenticateUser(username: String, password: String, completionHandler: (success: Bool, error: String?) -> Void) {
        
        let baseUrl = UdacityClient.Constants.BaseURL
        let endpoint = UdacityClient.Constants.EndpointAuthSession
        let parameters = [String: AnyObject]()
        let credentials = ["\(UdacityClient.Constants.ParameterAuth)": [
            "\(UdacityClient.Constants.ParameterUser)": username,
            "\(UdacityClient.Constants.ParameterPass)": password
            ]
        ]
        
        
        OTMClient.sharedInstance().httpPostRequest(baseUrl, endpoint: endpoint, parameters: parameters, jsonBody: credentials) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(success: false, error: "There was a network error. Please try again.")
            } else {
                
                if let account = result.objectForKey("account") as? [String: AnyObject],
                   let session = result.objectForKey("session") as? [String: AnyObject]
                {
                    // Set base properties
                    OTMAccount.key = account["key"] as! String
                    OTMAccount.sessiom = session["id"] as! String
                    
                    // Get user data - this will detect if valid user too
                    self.getUserData()  { (success, error) in
                        completionHandler(success: success, error: error)
                    }
                    
                } else {
                    completionHandler(success: false, error: "Invalid credentials. Please try again.")
                }
            }
        }
    }
    
    func endSession(completionHandler: (success: Bool, error: String?) -> Void) {
        
        let baseUrl = UdacityClient.Constants.BaseURL
        let endpoint = UdacityClient.Constants.EndpointAuthSession
        
        OTMClient.sharedInstance().httpDeleteRequest(baseUrl, endpoint: endpoint) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(success: false, error: "There was a network error. Please try again.")
            } else {
                completionHandler(success: true, error: nil)
            }
        }
    }
    
    private func getUserData(completionHandler: (success: Bool, error: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        let httpHeaders = [String: String]()
        let baseUrl = UdacityClient.Constants.BaseURL
        var endpoint = UdacityClient.Constants.EndpointGetUserData
        endpoint = OTMClient.subtituteKeyInMethod(endpoint, key: UdacityClient.Constants.URLKeyUserID, value: OTMAccount.key!)!
        
        OTMClient.sharedInstance().httpGetRequest(baseUrl, endpoint: endpoint, parameters: parameters, httpHeaders: httpHeaders, isUdacity: true) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(success: false, error: "There was a network error. Please try again.")
            } else {
                
                if let user = result["user"] as? [String : AnyObject] {
                    
                    // ensure they are registered
                    let registered = user["_registered"] as? Bool
                    if registered == true {
                        
                        // set up the remaining user details
                        OTMAccount.firstname = user["first_name"] as! String
                        OTMAccount.lastname = user["last_name"] as! String
                        
                        completionHandler(success: true, error: nil)
                        
                    } else {
                        completionHandler(success: false, error: "Account is not registered.")
                    }
                    
                } else {
                    print("User not found")
                    print(result)
                    completionHandler(success: false, error: "Invalid email or password.")
                }
            }
        }
        
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
