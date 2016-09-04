//
//  InfomationPostingViewController.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 25/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import MapKit

class InfomationPostingViewController: BaseViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    private var mapString: String = ""
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    
    // MARK: Outlets
    
    // Generic elements / Views
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var submissionView: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    // Search View elements
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSearch: UIButton!
    
    // Submission View elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareTextfield: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    
    
    // MARK: Actions
    
    @IBAction func cancelPost(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSearchAction(sender: UIButton) {
        let location = locationTextfield.text!
        
        if location.isEmpty || location == "Enter your location here" {
            showAlert("", message: "Please enter your location")
        } else {
            
            toggleSearch(false)
            
            // Solution provided in Stackover flow, converted to Swift
            // http://stackoverflow.com/questions/18563084/how-to-get-lat-and-long-coordinates-from-address-string
            // http://stackoverflow.com/questions/31360885/clgeocoder-swift-2-version
            CLGeocoder().geocodeAddressString(location) { (placemarks, error) -> Void in
                
                if error != nil {
                    self.showAlert("", message: "Unable to locate specified location")
                    self.toggleSearch(true)
                } else if placemarks?.count > 0 {
                    
                    let placemark = placemarks?[0] as CLPlacemark?
                    let coordinate = placemark?.location?.coordinate
                    let annoation = MKPointAnnotation()
                    annoation.coordinate = coordinate!
                    
                    // store long and lat in our properties so we can use this for submission
                    self.latitude = (coordinate?.latitude)!
                    self.longitude = (coordinate?.longitude)!
                    self.mapString = (placemark?.name)!
                    
                    // Zoom map into region, Centralise map view to coordinates and add annotation to map view
                    let span = MKCoordinateSpanMake(0.0025, 0.0025)
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), span: span)
                    
                    self.mapView.scrollEnabled = false
                    self.mapView.addAnnotation(annoation)
                    self.mapView.centerCoordinate = coordinate!
                    self.mapView.regionThatFits(MKCoordinateRegionMake(region.center, region.span))
                    self.mapView.setRegion(region, animated: true)
                    
                    // show the submmission view
                    self.searchView.hidden = true
                    self.submissionView.hidden = false
                    self.btnCancel.titleLabel?.textColor = UIColor.whiteColor()
                }   
            }
        }
    }
    
    @IBAction func btnPreviewAction(sender: UIButton) {
        let shareUrl = shareTextfield.text!
        if verifyUrl(shareUrl) {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: shareUrl)!)
        }
    }
    
    @IBAction func btnSubmitAction(sender: UIButton) {
        toggleSubmission(false)
        let shareUrl = shareTextfield.text!
        
        if verifyUrl(shareUrl) {
            
            // process the submission
            ParseClient.sharedInstance().processInformationPost(mapString, mediaURL: shareUrl, latitude: latitude, longitude: longitude) { success, error in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.toggleSubmission(true)
                        self.showAlert("", message: error!)
                    }
                }
            }
        } else {
            toggleSubmission(true)
            showAlert("", message: "Please enter a valid link to share")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide the submission view
        submissionView.hidden = true
        
        // hide the preview link button
        btnPreview.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if the user has already got a Student Location object
        ParseClient.sharedInstance().queryStudentLocationForUser() { (success, error) in
            
            if success {
                // check if the user has existing post, if so post alert for user to decide to overwrite.
                if OTMAccount.hasInformationPosting {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showExistingPostAlert()
                    }
                }
            } else {
                // error silently here...user shouldn't care too much about this, and it will break the users flow when entering their data!
                print("could not find previous student location data.")
            }
        }
        
        // textfield delegates
        locationTextfield.delegate = self
        shareTextfield.delegate = self
    }
    
    // Helper function to enable or disable the search view
    func toggleSearch(enabled: Bool) {
        
        if enabled {
            activityIndicator.stopAnimating()
            locationTextfield.enabled = true
            btnSearch.enabled = true
            searchView.alpha = 1.0
        } else {
            activityIndicator.startAnimating()
            locationTextfield.enabled = false
            btnSearch.enabled = false
            searchView.alpha = 0.5
        }
    }
    
    // Helper function to enable or disable the submission view
    func toggleSubmission(enabled: Bool) {
        
        if enabled {
            activityIndicator.stopAnimating()
            shareTextfield.enabled = true
            btnSubmit.enabled = true
            submissionView.alpha = 1.0
        } else {
            activityIndicator.startAnimating()
            shareTextfield.enabled = false
            btnSubmit.enabled = false
            submissionView.alpha = 0.5
        }
    }
    
    // Helper function to ensure the share URL is valid
    // Taken from Stackoverflow - http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    
    // MARK: Textfield
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // tag which flags this is the share link textfield
        if textField.tag == 1 {
            btnPreview.hidden = false
        }
        
        return true
    }
    
    
    // MARK: MapView 
    
    func mapView (mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView:MKPinAnnotationView = MKPinAnnotationView()
        pinView.annotation = annotation
        pinView.pinTintColor = UIColor.redColor()
        pinView.animatesDrop = true
        pinView.canShowCallout = false
            
        return pinView
    }
}
