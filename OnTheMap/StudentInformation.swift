//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 22/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    
    // Properties sent by Parse for each student location
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String

    // custom properties required for Map
    var coordinate: CLLocationCoordinate2D
    
    init(data: NSDictionary) {

        // setup custom coordinate property
        coordinate = CLLocationCoordinate2D(
            latitude: data["latitude"] as! Double,
            longitude: data["longitude"] as! Double
        )
        
        // setup default properties from dataset
        objectId = data["objectId"] as! String
        uniqueKey = data["uniqueKey"] as! String
        firstName = data["firstName"] as! String
        lastName = data["lastName"] as! String
        mapString = data["mapString"] as! String
        mediaURL = data["mediaURL"] as! String
        latitude = data["latitude"] as! Double
        longitude = data["longitude"] as! Double
        createdAt = data["createdAt"] as! String
        updatedAt = data["updatedAt"] as! String
    }
}