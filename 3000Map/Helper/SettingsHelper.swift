//
//  SettingsHelper.swift
//  3000Map
//
//  Created by rlbot on 2020/7/12.
//  Copyright © 2020 WL. All rights reserved.
//

import Foundation

class SettingsHelper {
    
    static let  minuteList = [3, 5, 8, 13]
    private static let updateIntervalMinuteKey = "updateIntervalMinute"
    
    
    class func currentUpdateIntervalMinute() -> Int {
        return UserDefaults.standard.integer(forKey: updateIntervalMinuteKey)
    }
    
    class func saveUpdateIntervalMinute(_ minute: Int) -> Bool {
        if minuteList.contains(minute) {
            UserDefaults.standard.set(minute, forKey: updateIntervalMinuteKey)
            return true
        }
        return false
    }
    
    
}
