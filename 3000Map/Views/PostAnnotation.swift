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
    
    var hsnCd      = ""   //縣市代號
    var townCd     = ""   //鄉鎮區代號
    var storeCd    = ""   //分局代號
    var hsnNm      = ""   //縣市名稱
    var townNm     = ""   //鄉鎮區名稱
    var storeNm    = ""   //分局名稱
    var addr       = ""   //門市地址
    var zipCd      = ""   //郵遞區號
    var tel        = ""   //電話
    var busiTime   = ""   //營業時間
    var busiMemo   = ""   //營業備註
    var total      = ""   //存量
    var updateTime = ""   //異動時間
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.coordinate = coordinate
    }
}
