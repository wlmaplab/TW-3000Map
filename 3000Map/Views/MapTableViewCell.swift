//
//  MapTableViewCell.swift
//  3000Map
//
//  Created by rlbot on 2020/7/20.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {
    
    @IBOutlet var mapView : MKMapView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    // MARK: - Move Location Coordinate
    
    func moveToLocation(coordinate: CLLocationCoordinate2D, title: String) {
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        anno.title = title
        mapView.addAnnotation(anno)
        
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        let adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true)
    }

}
