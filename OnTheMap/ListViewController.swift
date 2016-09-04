//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Sukh Kalsi on 25/10/2015.
//  Copyright © 2015 Sukh Kalsi. All rights reserved.
//

import UIKit

class ListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    @IBOutlet weak var studentListTableView: UITableView!
    
    // View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: ParseClient.Constants.NotificationID, object: nil)
    }
    
    // Custom view controller functions
    
    // Load the data into the table
    func loadData() {

        ParseClient.sharedInstance().getStudentLocations() { (success, error) in
            
            if !success || error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert("Student location error", message: error!)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.studentListTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentListTableViewCell"
        let studentLocation = ParseClient.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentLocations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let toOpen = ParseClient.sharedInstance().studentLocations[indexPath.row]
        app.openURL(NSURL(string: toOpen.mediaURL)!)
    }
}
