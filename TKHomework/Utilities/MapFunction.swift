//
//  MapFunction.swift
//  MapGGG
//
//  Created by Nguyen Anh Viet on 06/15/16.
//  Copyright © 2016 NAV. All rights reserved.
//

import Foundation
import GoogleMaps

class MapFunction {
    
    private let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    private let baseURLGeocoding  = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    private var selectedRoute   : Dictionary<NSObject, AnyObject>!
    var overviewPolyline        : Dictionary<NSObject, AnyObject>!
    
    func getDirections(origin: String!, destination: String!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)) {
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                directionsURLString = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    do {
                        let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                        //debugPrint(dictionary)
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    } catch {
                        print(error)
                        completionHandler(status: "", success: false)
                    }
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    func getAddress(latitude: String, longitude: String, completionHandler: ((address: String, success: Bool) -> Void)) {

        let url = NSURL(string: "\(baseURLGeocoding)latlng=\(latitude),\(longitude)&key=\(GEOCODING_KEY)")
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            if let address = result[0]["formatted_address"] as? String {
                completionHandler(address: address, success: true)
            }
        } else {
            completionHandler(address: "", success: false)
        }
    }
    
    func getLatLng(address: String, completionHandler: ((position: CLLocationCoordinate2D?, success: Bool) -> Void)) {
        
        let url = NSURL(string: "\(baseURLGeocoding)address=\(address)&sensor=false")

        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                    
                    let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
                    let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
                    completionHandler(position: CLLocationCoordinate2D(latitude: lat,longitude: lon), success: true)
                }
                
            }catch {
                completionHandler(position: nil, success: false)
            }
        }
        task.resume()

    }
}
