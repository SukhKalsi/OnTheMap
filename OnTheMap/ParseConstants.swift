//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 16/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

// MARK: - ParseClient (Constants)

extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Parse Application ID
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: Rest API Key
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs (Only supporting secure URLs)
        static let BaseURL : String = "https://api.parse.com/"
        
        // MARK: Notification Identifier for when we click Refresh
        static let NotificationID : String = "RefreshParseStudentInformation"
    }
    
    struct HTTPHeaders {
        static let AppID : String = "X-Parse-Application-Id"
        static let ApiKey : String = "X-Parse-REST-API-Key"
    }
    
    struct StudentLocation {
        
        // MARK: URL Placeholder
        static let URLKeyObjectID : String = "objectId"
        
        // MARK: Endpoints
        static let Endpoint : String = "1/classes/StudentLocation"
        static let EndpointUpdate : String = ParseClient.StudentLocation.Endpoint + "{" + ParseClient.StudentLocation.URLKeyObjectID + "}"
    }
    
    // MARK: Parameters
    struct Parameters {
        
        // MARK: GET optional parameters
        static let GetLimit : String = "limit"
        static let GetSkip : String = "skip"
        static let GetOrder : String = "order"
        
        // MARK: GET Query required parameters
        static let GetQuery : String = "where"
        
        // MARK: JSON Body Post parameters
        static let JsonBodyKey : String = "uniqueKey"
        static let JsonBodyFirstname : String = "firstName"
        static let JsonBodyLastname : String = "lastName"
        static let JsonBodyMap : String = "mapString"
        static let JsonBodyMedia : String = "mediaURL"
        static let JsonBodyLatitude : String = "latitude"
        static let JsonBodyLongitude : String = "longitude"
    }
}