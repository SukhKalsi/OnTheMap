//
//  OTMUser.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 15/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation

struct OTMAccount {
    
    // Base properties
    static var key: String!
    static var sessiom: String!
    
    // Detail properties
    static var firstname: String!
    static var lastname: String!
    
    // custom property flags for updating or new Information Posting
    static var hasInformationPosting: Bool = false // do they have one?
    static var updateInformationPosting: Bool = false // does the user want us to update it?
    static var postObjectId: String = ""
}
