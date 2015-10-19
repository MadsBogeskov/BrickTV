//
//  AwesomeNetworkLayer.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation

public func createURL(service: String, resourceId: String) -> NSURL
{
    return NSURL(string: "http://services.catalogs.lego.com/api/\(service)/\(resourceId)?applicationName=BrickTV")!
}

public func doLotsOfRequests<T>(requests: [NSURLRequest], createObject: (NSDictionary) -> T, completionHandler: ([T] -> ()))
{
    let request = requests.last!
    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
        guard let data = data else {
            return
        }
        
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary else {
            return
        }
        
        let object = createObject(json)
        let remaining = requests[0..<requests.count - 1]
        
        if remaining.count > 1
        {
            doRequest(Array(remaining), createObject: createObject, currentObjects: [object], completionHandler: completionHandler)
        }
        else
        {
            completionHandler([object])
        }
    }).resume()
}

public func doRequest<T>(requests: [NSURLRequest], createObject: (NSDictionary) -> T, currentObjects: [T], completionHandler: ([T] -> ()))
{
    let request = requests.last!
    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
        guard let data = data else {
            return
        }
        
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary else {
            return
        }
        
        let object = createObject(json)
        let remaining = requests[0..<requests.count - 1]
        
        let newObjects = currentObjects + [object]
        
        if remaining.count > 1
        {
            doRequest(Array(remaining), createObject: createObject, currentObjects: newObjects, completionHandler: completionHandler)
        }
        else
        {
            completionHandler(newObjects)
        }
    }).resume()
}