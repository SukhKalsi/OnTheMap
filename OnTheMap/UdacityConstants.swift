//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 14/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs (Only supporting secure URLs)
        static let BaseURL : String = "https://www.udacity.com/"
        
        // MARK: URL
        static let URLKeyUserID : String = "user_id"
        
        // MARK: Endpoints
        static let EndpointAuthSession : String = "api/session"
        static let EndpointGetUserData : String = "api/users/{" + UdacityClient.Constants.URLKeyUserID + "}"
        
        // MARK: Parameters
        static let ParameterAuth : String = "udacity"
        static let ParameterUser : String = "username" // Users email
        static let ParameterPass : String = "password"
    }
}