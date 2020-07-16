//
//  LevelsColor.swift
//  3000Map
//
//  Created by rlbot on 2020/7/8.
//  Copyright © 2020 WL. All rights reserved.
//

import UIKit

class LevelsColor {
    
    class func levelWith(total: Int) -> Int {
        /*
         *  level 5 : total >= 100
         *  level 4 : total >= 50 and total < 100
         *  level 3 : total >= 10 and total < 50
         *  level 2 : total > 0 and total < 10
         *  level 1 : total = 0
         */
        
        if total == 0 {
            return 1
        } else if total > 0 && total < 10 {
            return 2
        } else if total >= 10 && total < 50 {
            return 3
        } else if total >= 50 && total < 100 {
            return 4
        } else if total >= 100 {
            return 5
        }
        return 0
    }
    
    class func fontColorWith(total: Int) -> UIColor {
        /*
         *  Blue   : level 5
         *  Green  : level 4
         *  Orange : level 3
         *  Purple : level 2
         *  Red    : level 1
         */
        
        let level = levelWith(total: total)
        switch level {
        case 1:
            // #ea0000 => Red
            return UIColor(red: 234/255.0, green: 0, blue: 0, alpha: 1)
        case 2:
            // #ae00ae => Purple
            return UIColor(red: 174/255.0, green: 0, blue: 174/255.0, alpha: 1)
        case 3:
            // #ea7500 => Orange
            return UIColor(red: 234/255.0, green: 117/255.0, blue: 0, alpha: 1)
        case 4:
            // #019858 => Green
            return UIColor(red: 1/255.0, green: 152/255.0, blue: 88/255.0, alpha: 1)
        case 5:
            // #0072e3 => Blue
            return UIColor(red: 0, green: 114/255.0, blue: 227/255.0, alpha: 1)
        default:
            return UIColor.lightGray
        }
    }
    
    
    class func postImageNameWith(total: Int) -> String {
        /*
        *  Blue   : level 5
        *  Green  : level 4
        *  Orange : level 3
        *  Purple : level 2
        *  Red    : level 1
        */
        
        let level = levelWith(total: total)
        switch level {
        case 1:
            return "post_pin_red"
        case 2:
            return "post_pin_purple"
        case 3:
            return "post_pin_orange"
        case 4:
            return "post_pin_green"
        case 5:
            return "post_pin_blue"
        default:
            return "post_pin"
        }
    }
    
}
