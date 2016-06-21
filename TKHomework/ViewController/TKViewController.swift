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
    @IBOutlet weak var toInput  : UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchResults    = [String]()
    private var currentTextfield = UITextField()
    private var mapFunction      = MapFunction()
    
    private var fromMarker       : GMSMarker?
    private var toMarker         : GMSMarker?
    private var routePolyline    : GMSPolyline?
    
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
        toInput.addTarget(self, action: #selector(TKViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    // handle event EditingChanged
    func textFieldDidChange(textField: UITextField) {
        let placeClient = GMSPlacesClient()
        let filter = GMSAutocompleteFilter()
        self.searchResults.removeAll()
        filter.type = .Address
        filter.country = "vn"
        let characterSet = NSCharacterSet.whitespaceCharacterSet()
        let searchInput  = textField.text!.stringByTrimmingCharactersInSet(characterSet)
        if checkValidInput(searchInput) {
            placeClient.autocompleteQuery(searchInput, bounds: nil, filter: filter) { (results, error: NSError?) -> Void in
                
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
    
    func checkValidInput(input : String) -> Bool {
        if !input.isEmpty {
            
            /* Pattern for check Address if need */
            //            let regex = ""
            //            do {
            //                let regex = try NSRegularExpression(pattern: regex, options: .CaseInsensitive)
            //                return regex.firstMatchInString(input, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, input.characters.count)) != nil
            //            } catch {
            //                return false
            //            }
            
            return true
        }
        return false
    }
    
    // show marker
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let position = CLLocationCoordinate2DMake(lat, lon)
            
            if self.currentTextfield == self.fromInput {
                if self.fromMarker == nil {
                    self.fromMarker = GMSMarker(position: position)
                }
                self.fromMarker?.position  = position
                self.fromMarker!.draggable = true
                self.fromMarker!.title     = "Address : \(title)"
                self.fromMarker!.map       = self.mapView
            } else if self.currentTextfield == self.toInput {
                if self.toMarker == nil {
                    self.toMarker = GMSMarker(position: position)
                }
                self.toMarker?.position  = position
                self.toMarker!.draggable = true
                self.toMarker!.title     = "Address : \(title)"
                self.toMarker!.map       = self.mapView
            }
            
            if let fromMarker = self.fromMarker, toMarker = self.toMarker {
                self.recreateRoute()
                let bounds = GMSCoordinateBounds(coordinate: fromMarker.position, coordinate: toMarker.position)
                self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
            } else {
                let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 14)
                self.mapView.camera = camera
            }
        }
    }
    
    func recreateRoute() {
        if let _ = routePolyline {
            routePolyline!.map = nil
            routePolyline      = nil
        }
        mapFunction.getDirections("\(fromMarker!.position.latitude),\(fromMarker!.position.longitude)", destination: "\(toMarker!.position.latitude),\(toMarker!.position.longitude)", travelMode: nil, completionHandler: { (status, success) -> Void in
            
            if success {
                self.drawRoute()
            }
            else {
                print(status)
            }
        })
    }
    
    func drawRoute() {
        let route = mapFunction.overviewPolyline["points"] as! String
        let path: GMSPath  = GMSPath(fromEncodedPath: route)!
        routePolyline      = GMSPolyline(path: path)
        routePolyline!.map = mapView
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
    
    func mapView(mapView: GMSMapView, didEndDraggingMarker marker: GMSMarker) {
        mapFunction.getAddress(String(marker.position.latitude), longitude: String(marker.position.longitude)) { (address, success) in
            if !success {
                return
            }
            if marker == self.fromMarker {
                self.fromInput.text = address
            } else if marker == self.toMarker {
                self.toInput.text = address
            }
        }
        if let fromMarker = self.fromMarker, toMarker = self.toMarker {
            self.recreateRoute()
            let bounds = GMSCoordinateBounds(coordinate: fromMarker.position, coordinate: toMarker.position)
            self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
        }
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        tableView.hidden = true
        currentTextfield.text = searchResults[indexPath.row]
        currentTextfield.resignFirstResponder()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
        mapFunction.getLatLng(correctedAddress) { (position, success) in
            if !success {
                return
            }
            if let position = position {
                self.locateWithLongitude(position.longitude, andLatitude: position.latitude, andTitle: self.searchResults[indexPath.row])
            }
        }
    }
    
}