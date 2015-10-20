//
//  AwesomeNetworkLayer.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation

let cookie = "PROMARKETPREF=en-US; MARKETPREF=en-US; X-Node-ABC=LEW-A01; .ASPXAUTH=89D29DA57F484D3BEAE72FDBC070FE096807CD97FADE9851457C2A3F57380EEDDBB7530F98C5D19CCB9DB6015DF0504C6FE3BF8DA740B62D59C4834A76DFF00DEFF99B227B9332171ADBB29DC0E61FF94EFCAC9DB0C715F45E6467F52A8DB88EF0B4B3B75DB39BFDDD7DA874D9A84055F998AAA345D481E9D9718DDF4FCE67C543835A797490DE4F89A20298DB72CC0BB858938858383B0194D7761285EBA448C2F69733; L.S.4=c372946f-e963-41ea-9717-d36653993e01; s_pers=%20s_fid%3D1EDEAF413B331DF1-2BB30A14B86418C0%7C1508481782420%3B%20c_dl%3D1%7C1445325182422%3B; s_sess=%20s_cc%3Dtrue%3B%20s_clientPerformance_persist%3Daccount2%253Ahomepage%253Asignin%257C1-3%3B%20s_sq%3D%3B; s_vi=[CS]v1|2AE98CA78530AD6B-60000301A005E284[CE]; X-Node-E=LEW-E03; X-LB=NLALEL-A01-A02; L.S=c372946f-e963-41ea-9717-d36653993e01"
let csrfToken = "c372946f-e963-41ea-9717-d36653993e01"

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

public func doLotsOfRequests<T>(requests: [NSURLRequest], createObject: (NSDictionary) -> T?, completionHandler: ([T] -> ()))
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
        
        if remaining.count > 0
        {
            doRequest(Array(remaining), createObject: createObject, currentObjects: object != nil ? [object!] : [], completionHandler: completionHandler)
        }
        else
        {
            if let object = object
            {
                completionHandler([object])
            }
            else
            {
                completionHandler([])
            }
        }
    }).resume()
}

public func doRequest<T>(requests: [NSURLRequest], createObject: (NSDictionary) -> T?, currentObjects: [T], completionHandler: ([T] -> ()))
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
        
        let newObjects = object != nil ? currentObjects + [object!] : currentObjects
        
        if remaining.count > 0
        {
            doRequest(Array(remaining), createObject: createObject, currentObjects: newObjects, completionHandler: completionHandler)
        }
        else
        {
            completionHandler(newObjects)
        }
    }).resume()
}


// curl 'https://services.videouserdata.lego.com/api/v1/views/0b91ab4a-a618-4145-a53c-beb541162fb8?csrfToken=c372946f-e963-41ea-9717-d36653993e01' 
// -X POST
// -H 'Pragma: no-cache'

// -H 'Origin: https://services.videouserdata.lego.com'
// -H 'Accept-Encoding: gzip, deflate'
// -H 'Accept-Language: en-US,en;q=0.8'
// -H 'csrfToken: c372946f-e963-41ea-9717-d36653993e01'
// -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
// -H 'Accept: */*'
// -H 'Cache-Control: no-cache'
// -H 'X-Requested-With: XMLHttpRequest'
// -H 'Cookie: PROMARKETPREF=da-DK; MARKETPREF=da-DK; X-Node-ABC=LEW-A01; .ASPXAUTH=89D29DA57F484D3BEAE72FDBC070FE096807CD97FADE9851457C2A3F57380EEDDBB7530F98C5D19CCB9DB6015DF0504C6FE3BF8DA740B62D59C4834A76DFF00DEFF99B227B9332171ADBB29DC0E61FF94EFCAC9DB0C715F45E6467F52A8DB88EF0B4B3B75DB39BFDDD7DA874D9A84055F998AAA345D481E9D9718DDF4FCE67C543835A797490DE4F89A20298DB72CC0BB858938858383B0194D7761285EBA448C2F69733; L.S.4=c372946f-e963-41ea-9717-d36653993e01; s_pers=%20s_fid%3D1EDEAF413B331DF1-2BB30A14B86418C0%7C1508481782420%3B%20c_dl%3D1%7C1445325182422%3B; s_sess=%20s_cc%3Dtrue%3B%20s_clientPerformance_persist%3Daccount2%253Ahomepage%253Asignin%257C1-3%3B%20s_sq%3D%3B; s_vi=[CS]v1|2AE98CA78530AD6B-60000301A005E284[CE]; X-Node-E=LEW-E03; X-LB=NLALEL-A01-A02; L.S=c372946f-e963-41ea-9717-d36653993e01'
// -H 'Connection: keep-alive'
// -H 'Referer: https://services.videouserdata.lego.com/test?lidreload=1445323382433'
// -H 'Content-Length: 0' --compressed
func registerViewOn(video: Video) {
    let urlString = "https://services.videouserdata.lego.com/api/v1/views/\(video.id)?csrfToken=\(csrfToken)"
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue(csrfToken, forHTTPHeaderField: "csrfToken")
    request.addValue(cookie, forHTTPHeaderField: "Cookie")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("0", forHTTPHeaderField: "Content-Length")
    NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
        print(NSString(data: data!, encoding: 4), response, error)
    }.resume()
}
