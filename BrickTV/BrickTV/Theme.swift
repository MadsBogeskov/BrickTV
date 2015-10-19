//
//  Theme.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class Theme: CustomStringConvertible {
    let ageFrom: Int
    let ageTo: Int
    
    let bannerImages: String
    let themeDescription: String
    
    let id: String
    
    let key: String
    
    let logoUrl: NSURL?
    
    let primaryImageUrl: NSURL?
    
    let themeColor: String
    
    let thumbnailUrl: NSURL?
    var thumbnailImage = UIImage(named: "ThemeThumbnailPlaceholder")!
    
    let title: String
    
    let trackingId: String
    
    init(json: NSDictionary)
    {
        self.ageFrom = json["AgeFrom"] as? Int ?? 0
        self.ageTo = json["AgeTo"] as? Int ?? 0
        self.bannerImages = json["BannerImages"] as? String ?? ""
        self.themeDescription = json["Description"] as? String ?? ""
        self.id = json["Id"] as? String ?? ""
        self.key = json["Key"] as? String ?? ""
        self.logoUrl = NSURL(string: json["LogoURL"] as? String ?? "")
        self.primaryImageUrl = NSURL(string: json["PrimaryImageUrl"] as? String ?? "")
        self.themeColor = json["ThemeColor"] as? String ?? ""
        self.thumbnailUrl = NSURL(string: json["ThumbnailUrl"] as? String ?? "")
        self.title = json["Title"] as? String ?? ""
        self.trackingId = json["TrackingId"] as? String ?? ""
    }
    
    func loadVideos(completionHandler: [Video] -> ())
    {
        let postData = "HiddenConstraints=\"LegoCatalogType\":\"LegoVideo\" AND \"LegoTheme\":\"\(key)\"&SelectProperties[]=LegoId,LegoTitle"
        let UrlString = "https://wwwsecure.lego.com/query/api/search?applicationName=BrickTV&legoapikey=BrickTV%3A31-10-2015%231%231%23fZ%2BS%2FZ%2BzKIcUWw6%2BVIe2Jg%3D%3D"
        
        let url = NSURL(string: UrlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Content-Length", forHTTPHeaderField: String(request.HTTPBody?.length ?? 0))
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, reponse, error) -> Void in
            guard let data = data else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
                return
            }
            
            guard let primaryResults = json["PrimaryResults"] as? NSDictionary else {
                return
            }
            guard let items = primaryResults["Items"] as? NSArray else {
                return
            }
            
            var requests: [NSMutableURLRequest] = []
            for item in (items as? [NSDictionary])!
            {
                let id = item["Id"] as! String
                
                let trimmedId = id.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "{}"))
                
                guard let url = NSURL(string: "https://wwwsecure.lego.com/en-US/mediaplayer/api/video.json/\(trimmedId)") else {
                    continue
                }
                
                requests.append(NSMutableURLRequest(URL: url))//createURL("Video", resourceId: trimmedId)))
            }
            
            doLotsOfRequests(requests, createObject: { (dic) -> Video in
                Video(json: dic)
                }, completionHandler: { (objs) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.videos = objs
                        completionHandler(objs)
                    })
            })
        }).resume()
    }
    
    var videos = [Video]()
    
    var description: String {
        get {
            return "id: \(id) -> title: \(title)"
        }
    }
}

extension Theme {
    func loadThumbnailImage(completion: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let image = UIImage(data: NSData(contentsOfURL: self.thumbnailUrl!)!)!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.thumbnailImage = image
                completion()
            })
        }
    }
}