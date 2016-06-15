//
//  TKViewController.swift
//  TKHomework
//
//  Created by NAV on 6/15/16.
//  Copyright © 2016 Nguyen Anh Viet. All rights reserved.
//

import UIKit
import GoogleMaps

class TKViewController: UIViewController {
    
    @IBOutlet weak var mapView  : GMSMapView!
    @IBOutlet weak var fromInput: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults    = [String]()
    var currentTextfield = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // registe Cell for table
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "identifierCell")
        
        // set camera for map
        let camera       = GMSCameraPosition.cameraWithLatitude(10.797919, longitude: 106.658412, zoom: 14)
        mapView.delegate = self
        mapView.camera   = camera
        
        // add event EditingChanged for textField
        fromInput.addTarget(self, action: #selector(TKViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        fromInput.delegate = self
        
    }
    
    // handle event EditingChanged
    func textFieldDidChange(textField: UITextField) {
        let placeClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        self.searchResults.removeAll()
        filter.type = .Address
        filter.country = "vn"
        if let searchText = textField.text where !textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty{
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: filter) { (results, error: NSError?) -> Void in
                
                guard error == nil else {
                    print("Autocomplete error \(error)")
                    return
                }
                
                for result in results! {
                    self.searchResults.append(result.attributedFullText.string)
                }
                
                self.tableView.reloadData()
                
            }
        } else {
            self.tableView.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // show marker
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 14)
            self.mapView.camera = camera
            
            marker.title = "Address : \(title)"
            marker.map = self.mapView
            
            print("Ahihi :: \(lat) \n Longitude :: \(lon)")
            
        }
        
    }
}

//MARK: - UITextFieldDelegate
extension TKViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        currentTextfield = textField
        return true
    }
}

//MARK: - GMSMapViewDelegate
extension TKViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        currentTextfield.resignFirstResponder()
        currentTextfield.endEditing(true)
    }
}

//MARK: - UITableViewDataSource
extension TKViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.hidden = !(self.searchResults.count > 0)
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("identifierCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate
extension TKViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.hidden = true
        currentTextfield.text = searchResults[indexPath.row]
        currentTextfield.resignFirstResponder()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                    
                    let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
                    let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
                    self.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row])
                }
                
            }catch {
                print("Error")
            }
        }
        task.resume()
    }
    
}