//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 14/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

// MARK: ParseClient: NSObject

class ParseClient: NSObject {
    
    var studentLocations: [StudentInformation] = []
    
    override init() {
        super.init()
    }
    
    func getStudentLocations(limit: Int = 100, skip: Int = 0, order: String = "-updatedAt", completionHandler: (success: Bool, error: String?) -> Void) {
        
        let parameters = [
            "limit": limit,
            "skip": skip,
            "order": order
        ]
        
        // configure the additional http headers
        let httpHeaders = [
            ParseClient.HTTPHeaders.AppID : ParseClient.Constants.AppID,
            ParseClient.HTTPHeaders.ApiKey : ParseClient.Constants.ApiKey
        ]
        
        let baseUrl = ParseClient.Constants.BaseURL
        let endpoint = ParseClient.StudentLocation.Endpoint
        
        OTMClient.sharedInstance().httpGetRequest(baseUrl, endpoint: endpoint, parameters: parameters as! [String : AnyObject], httpHeaders: httpHeaders) { result, error in
            
            if let error = error {
                print(error)
                completionHandler(success: false, error: "There was a network error. Please try again.")
            } else {
                
                // Ensure we have result set, then append to our Student Locations array of type Parse Student object
                if let results = result["results"] as? [NSDictionary] {
                    
                    // empty the collection
                    self.studentLocations = []
                    
                    // now loop and add to collection
                    for data in results {
                        self.studentLocations.append(StudentInformation(data: data))
                    }
                    
                    completionHandler(success: true, error: nil)
                    
                } else {
                    print("No location result set found.")
                    print(result)
                    completionHandler(success: false, error: "Could not retrieve student location data.")
                }
            }
        }
    }
    
    // Query the Parse API using the Users Key
    func queryStudentLocationForUser(completionHandler: (success: Bool, error: String?) -> Void) {
        let baseUrl = ParseClient.Constants.BaseURL
        let endpoint = ParseClient.StudentLocation.Endpoint
        let parameters = [
            "where": "%7B%22uniqueKey%22%3A%22\(OTMAccount.key)%22%7D"
        ]
        
        // configure the additional http headers
        let httpHeaders = [
            ParseClient.HTTPHeaders.AppID : ParseClient.Constants.AppID,
            ParseClient.HTTPHeaders.ApiKey : ParseClient.Constants.ApiKey
        ]
        
        OTMClient.sharedInstance().httpGetRequest(baseUrl, endpoint: endpoint, parameters: parameters, httpHeaders: httpHeaders, isUdacity: false, shouldEscapeParameters: false) { result, error in

            // Ensure we have result set, then append to our Student Locations array of type Parse Student object
            if let results = result["results"] as? [NSDictionary] {

                for data in results {
                    // just to double check...
                    if data["uniqueKey"] as! String == OTMAccount.key {
                        OTMAccount.hasInformationPosting = true // update the flag
                        
                        if OTMAccount.postObjectId.isEmpty {
                            OTMAccount.postObjectId = data["objectId"] as! String // set the object id so we can use this to update if the user requests so
                        }
                        break
                    }
                }
                
                completionHandler(success: true, error: nil)
                
            } else {
                completionHandler(success: false, error: "Could not retrieve student location data.")
            }
        }
    }
    
    // Information Posting processing
    func processInformationPost(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, error: String?) -> Void) {
        
        let baseUrl = ParseClient.Constants.BaseURL
        
        // endpoint has users key appended at end if we're updating
        let endpoint = ParseClient.StudentLocation.Endpoint + (OTMAccount.updateInformationPosting == true ? "/\(OTMAccount.postObjectId)" : "")
        
        // Empty parameters
        let parameters = [String: AnyObject]()
        
        // configure the additional http headers
        let httpHeaders = [
            ParseClient.HTTPHeaders.AppID : ParseClient.Constants.AppID,
            ParseClient.HTTPHeaders.ApiKey : ParseClient.Constants.ApiKey
        ]
        
        // the important bit - the data!
        let data: [String : AnyObject] = [
            "uniqueKey": OTMAccount.key,
            "firstName": OTMAccount.firstname,
            "lastName": OTMAccount.lastname,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        // detect whether we updating (PUT) or simply posting a new one (POST)
        if OTMAccount.updateInformationPosting {
            OTMClient.sharedInstance().httpPutRequest(baseUrl, endpoint: endpoint, parameters: parameters, jsonBody: data, isUdacity: false, httpHeaders: httpHeaders) { result, error in
                if let error = error {
                    print(error)
                    completionHandler(success: false, error: "There was a network error. Please try again.")
                } else {
                    if let updatedAt = result.objectForKey("updatedAt") as? String {
                        print("updated at: \(updatedAt)")
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: "Unable to update your post. Please try again.")
                    }
                }
            }
        } else {
            OTMClient.sharedInstance().httpPostRequest(baseUrl, endpoint: endpoint, parameters: parameters, jsonBody: data, isUdacity: false, httpHeaders: httpHeaders) { result, error in
                if let error = error {
                    print(error)
                    completionHandler(success: false, error: "There was a network error. Please try again.")
                } else {
                    
                    print(result)
                    
                    if let newObjectId = result.objectForKey("objectId") as? String {
                        // Update the object id
                        OTMAccount.postObjectId = newObjectId
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: "Unable to post your location. Please try again.")
                    }
                }
            }
        }
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}