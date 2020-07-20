//
//  AppVariables.swift
//  3000Map
//
//  Created by rlbot on 2020/7/19.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import CoreLocation

class AppVariables {
    
    // MARK: - items
     
    class func items() -> Array<Dictionary<String,Any>>? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.postItems
    }
    
    class func setItems(_ items: Array<Dictionary<String,Any>>?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.postItems = items
    }
    
    
    // MARK: - myLocation
    
    class func myLocation() -> CLLocationCoordinate2D {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.myLocation
    }
    
    class func setMyLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myLocation.latitude = latitude
        appDelegate.myLocation.longitude = longitude
    }
    
    
    // MARK: - opendPostDetailsStoreCd
    
    class func opendPostDetailsStoreCd() -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.opendPostDetailsStoreCd
    }
    
    class func setOpendPostDetailsStoreCd(_ storeCd: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.opendPostDetailsStoreCd = storeCd
    }
    
}
