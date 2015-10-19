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

public func tryGetUrl(dictionary: NSDictionary, key: String) -> NSURL?
{
    if let value = dictionary[key] as? String, let url = NSURL(string: value)
    {
        return url
    }
    
    return nil
}

public func doLotsOfRequests<T>(requests: [NSURLRequest], createObject: (NSDictionary) -> T, completionHandler: ([T] -> ()))
{
    guard let request = requests.last else {
        completionHandler([])
        return
    }

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
    guard let request = requests.last else {
        completionHandler(currentObjects)
        return
    }
    
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