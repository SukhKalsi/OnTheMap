//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 16/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // View lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: ParseClient.Constants.NotificationID, object: nil)
    }
    
    // Custom view controller functions
    
    // Load the data for the Map
    func loadData() {
        
        // remove existing annotations. Solution from Stackoverflow - http://stackoverflow.com/questions/10865088/how-do-i-remove-all-annotations-from-mkmapview-except-the-user-location-annotati
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        ParseClient.sharedInstance().getStudentLocations() { (success, error) in
            
            if success {
                // Instantiate Map Annotations array
                var annotations = [MKPointAnnotation]()
                
                // Loop through all the Student Locations and instantiate a Point Annotation
                for studentLocation in ParseClient.sharedInstance().studentLocations {
                    
                    // Create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = studentLocation.coordinate
                    annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                    annotation.subtitle = studentLocation.mediaURL
                    
                    // Place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                // Resolved issue where pins only show when moving map. Pushed to UI Thread. See Stackoverflow - http://stackoverflow.com/questions/12096091/mapkit-annotation-views-dont-display-until-scrolling-the-map
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(annotations)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Student location error", message: error!)
                }
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}
