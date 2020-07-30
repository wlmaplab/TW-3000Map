//
//  MyTools.swift
//  3000Map
//
//  Created by rlbot on 2020/7/20.
//  Copyright © 2020 WL. All rights reserved.
//

import Foundation

class MyTools {
    
    class func searchPostInfoWith(storeCd: String, from postItems: Array<PostItem>) -> PostItem? {
        if storeCd == "" { return nil }
        
        for item in postItems {
            if let itemStoreCd = item.storeCd, itemStoreCd == storeCd {
                return item
            }
        }
        return nil
    }
    
}
