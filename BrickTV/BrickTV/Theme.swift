//
//  Theme.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation

class Theme
{
    let ageFrom: Int;
    let ageTo: Int;
    
    let bannerImages: String;
    let description: String;
    
    let id: String;
    
    let key: String;
    
    let logoUrl: NSURL?;
    
    let primaryImageUrl: NSURL?
    
    let themeColor: String;
    
    let thumbnailUrl: NSURL?;
    
    let title: String;
    
    let trackingId: String;
    
    init(json: NSDictionary)
    {
        self.ageFrom = json["AgeFrom"] as? Int ?? 0
        self.ageTo = json["AgeTo"] as? Int ?? 0
        self.bannerImages = json["BannerImages"] as? String ?? ""
        self.description = json["Description"] as? String ?? ""
        self.id = json["Id"] as? String ?? ""
        self.key = json["Key"] as? String ?? ""
        self.logoUrl = NSURL(string: json["LogoURL"] as? String ?? "")
        self.primaryImageUrl = NSURL(string: json["PrimaryImageUrl"] as? String ?? "")
        self.themeColor = json["ThemeColor"] as? String ?? ""
        self.thumbnailUrl = NSURL(string: json["ThumbnailUrl"] as? String ?? "")
        self.title = json["Title"] as? String ?? ""
        self.trackingId = json["TrackingId"] as? String ?? ""
    }
    
    func videos(completionHandler: [Video] -> ())
    {
        let postData = "HiddenConstraints=\"LegoCatalogType\":\"LegoVideo\" AND \"LegoTheme\":\"Star Wars\"\nSelectProperties[]=LegoId,LegoTitle"
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
            
            print (request)
            print(json)
            
            guard let items = primaryResults["Items"] as? NSArray else {
                return
            }
            
            let videos = items.map {
                Video(json: $0 as! NSDictionary)
            }
            
            completionHandler(videos)
        }).resume()
    }
}