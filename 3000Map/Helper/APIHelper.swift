//
//  APIHelper.swift
//  3000Map
//
//  Created by rlbot on 2020/7/1.
//  Copyright © 2020 WL. All rights reserved.
//

import Foundation

class APIHelper {
    
    static let apiURLString = "https://3000.gov.tw/hpgapi-openmap/api/getPostData"

    
    // MARK: - Fetch Data
    
    class func fetchData(callback: @escaping (Array<Dictionary<String,Any>>?) -> Void) {
        httpGET_withFetchJsonObject(URLString: apiURLString, callback: callback)
    }
    
    
    // MARK: - HTTP GET
    
    class func httpGET_withFetchJsonObject(URLString: String, callback: @escaping (Array<Dictionary<String,Any>>?) -> Void) {
        httpRequestWithFetchJsonArray(httpMethod: "GET", URLString: URLString, parameters: nil, callback: callback)
    }
    
    
    // MARK: - HTTP Request with Method
    
    class func httpRequestWithFetchJsonArray(httpMethod: String,
                                             URLString: String,
                                             parameters: Dictionary<String, Any>?,
                                             callback: @escaping (Array<Dictionary<String,Any>>?) -> Void)
    {
        // Create request
        let url = URL(string: URLString)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        // Header
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        // Body
        if let parameterDict = parameters {
            // parameter dict to json data
            let jsonData = try? JSONSerialization.data(withJSONObject: parameterDict)
            // insert json data to the request
            request.httpBody = jsonData
        }
        
        // Task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    callback(nil)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let json = responseJSON as? Array<Dictionary<String,Any>> {
                    callback(json)
                } else {
                    callback(nil)
                }
            }
        }
        task.resume()
    }
    
}
