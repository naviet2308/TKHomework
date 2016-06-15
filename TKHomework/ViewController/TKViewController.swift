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

    @IBOutlet weak var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera       = GMSCameraPosition.cameraWithLatitude(10.797919, longitude: 106.658412, zoom: 14)
        mapView.delegate = self
        mapView.camera   = camera
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TKViewController: GMSMapViewDelegate {
    
}