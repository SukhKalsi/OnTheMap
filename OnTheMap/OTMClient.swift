//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 14/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

// MARK: OTMClient: NSObject

class OTMClient: NSObject {
    
    /* Shared session */
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: GET request
    // Hack: isUdacity parameter here to identify if the call is from UdacityClient. If so, we need to sub string 5 characters in JSON response for parsing!
    // Hack 2: shouldEscapeParameters parameter is here to flag when we want to skip escaping the parameters. This is due to Parse API getting student location by key call, where we have JSON as the get clause.
    func httpGetRequest(baseUrl: String, endpoint: String, parameters: [String : AnyObject], httpHeaders: [String : String], isUdacity: Bool = false, shouldEscapeParameters: Bool = true, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Setup the URL we want to request to */
        let urlString = baseUrl + endpoint + OTMClient.escapedParameters(parameters, shouldEscape: shouldEscapeParameters)
        
        print(urlString)
        let url = NSURL(string: urlString)!
        
        /* Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* Add additional HTTP Headers, if there are any i.e. Parse client */
        for (httpHeader, httpValue) in httpHeaders {
            request.addValue(httpValue, forHTTPHeaderField: httpHeader)
        }
        
        /* Make the Request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                // generic error
                let userInfo = [NSLocalizedDescriptionKey : "The server is unavailable."]
                
                if let response = response as? NSHTTPURLResponse {
                    
                    guard let data = data else {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                        completionHandler(result: nil, error: NSError(domain: "HTTP_Get_NSHTTPURLResponse_without_data", code: 1, userInfo: userInfo))
                        return
                    }
                    
                    OTMClient.parseJSONWithCompletionHandler(data, isUdacity: isUdacity, completionHandler: completionHandler)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_Get_with_Response", code: 1, userInfo: userInfo))
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_Get_without_Response", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Your data could not be retrieved from the server."]
                completionHandler(result: nil, error: NSError(domain: "HTTP_Get_has_2xx_response_without_data", code: 1, userInfo: userInfo))
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, isUdacity: isUdacity, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: POST request. Optional httpHeaders here.
    
    func httpPostRequest(baseUrl: String, endpoint: String, parameters: [String : AnyObject], jsonBody: [String : AnyObject], isUdacity: Bool = true, httpHeaders: [String : String] = [String: String](), completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Setup the URL we want to request to */
        let urlString = baseUrl + endpoint + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Add additional HTTP Headers, if there are any i.e. Parse client */
        for (httpHeader, httpValue) in httpHeaders {
            request.addValue(httpValue, forHTTPHeaderField: httpHeader)
        }
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                // generic error
                let userInfo = [NSLocalizedDescriptionKey : "The server is unavailable."]
                
                if let response = response as? NSHTTPURLResponse {
                    guard let data = data else {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                        completionHandler(result: nil, error: NSError(domain: "HTTP_POST_NSHTTPURLResponse_without_data", code: 1, userInfo: userInfo))
                        return
                    }
                    
                    OTMClient.parseJSONWithCompletionHandler(data, isUdacity: isUdacity, completionHandler: completionHandler)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_POST_with_Response", code: 1, userInfo: userInfo))
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_POST_without_Response", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "Your data could not be retrieved from the server."]
                completionHandler(result: nil, error: NSError(domain: "HTTP_POST_has_2xx_response_without_data", code: 1, userInfo: userInfo))
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, isUdacity: isUdacity, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: DELETE request - only used for logout.
    
    func httpDeleteRequest(baseUrl: String, endpoint: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Setup the URL we want to request to */
        let urlString = baseUrl + endpoint
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* Handling the cookie */
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* Make the Request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // As this is only called from Udacity Client (for time being), we hard coding this in. Follow same steps to Get if we require this dynamic!
            OTMClient.parseJSONWithCompletionHandler(data, isUdacity: true, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: PUT request - only used for Parse. Optional httpHeaders here.
    
    func httpPutRequest(baseUrl: String, endpoint: String, parameters: [String : AnyObject], jsonBody: [String : AnyObject], isUdacity: Bool = true, httpHeaders: [String : String] = [String: String](), completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Setup the URL we want to request to */
        let urlString = baseUrl + endpoint + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Add additional HTTP Headers, if there are any i.e. Parse client */
        for (httpHeader, httpValue) in httpHeaders {
            request.addValue(httpValue, forHTTPHeaderField: httpHeader)
        }
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                // generic error
                let userInfo = [NSLocalizedDescriptionKey : "The server is unavailable."]
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    
                    guard let data = data else {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                        completionHandler(result: nil, error: NSError(domain: "HTTP_PUT_NSHTTPURLResponse_without_data", code: 1, userInfo: userInfo))
                        return
                    }
                    
                    // As this is only called from Parse Client (for time being), we hard coding this in. Follow same steps to Get if we require this dynamic!
                    OTMClient.parseJSONWithCompletionHandler(data, isUdacity: false, completionHandler: completionHandler)
                    
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_PUT_with_Response", code: 1, userInfo: userInfo))
                } else {
                    print("Your request returned an invalid response!")
                    completionHandler(result: nil, error: NSError(domain: "HTTP_PUT_without_Response", code: 1, userInfo: userInfo))
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "Your data could not be retrieved from the server."]
                completionHandler(result: nil, error: NSError(domain: "HTTP_PUT_has_2xx_response_without_data", code: 1, userInfo: userInfo))
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            // As this is only called from Parse Client (for time being), we hard coding this in. Follow same steps to Get if we require this dynamic!
            OTMClient.parseJSONWithCompletionHandler(data, isUdacity: false, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, isUdacity: Bool, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        /* subset response data if Udacity only! */
        let data = isUdacity ? data.subdataWithRange(NSMakeRange(5, data.length - 5)) : data
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject], shouldEscape: Bool = true) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = shouldEscape ? stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) : stringValue
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
}