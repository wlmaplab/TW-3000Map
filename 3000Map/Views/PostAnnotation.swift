//
//  PostAnnotation.swift
//  3000Map
//
//  Created by rlbot on 2020/7/3.
//  Copyright © 2020 WL. All rights reserved.
//

import Foundation
import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var image : UIImage?
    var info : PostItem?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
}
