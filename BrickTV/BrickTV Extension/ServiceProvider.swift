//
//  ServiceProvider.swift
//  BrickTV Extension
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {

    var videos: [LegoVideo] = []
    
    override init() {
        super.init()
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "https://a248.e.akamai.net/cache.lego.com/r/www/r/services/contentpromotionapi/api/v1/contentpromotion/list-of-items/801053aa-0d6a-4ec8-9606-3dabbe513d43/Video/com.lego.friends.hubapp/iPhone/7/0/1?languageVersion=en-US")!, completionHandler: { (data, response, error) -> Void in
            guard let data = data, let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary else {
                return
            }
            
            guard let json2 = json else {
                return
            }

            guard let contents = json2["Content"] as? NSArray else {
                return
            }
            
            self.videos = contents.map {
                LegoVideo(json: $0 as! NSDictionary)
            }
            
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: TVTopShelfItemsDidChangeNotification, object: nil))
            
        }).resume()
    }

    // MARK: - TVTopShelfProvider protocol

    var topShelfStyle: TVTopShelfContentStyle {
        return .Inset
    }

    var topShelfItems: [TVContentItem] {
        
        var items: [TVContentItem] = []
        for video in videos
        {
            let contentIdentifier = TVContentIdentifier(identifier: video.id, container: nil)!
            let contentItem = TVContentItem(contentIdentifier: contentIdentifier)
            
            contentItem!.title = video.title
            contentItem!.displayURL = video.thumbnailUrl
            contentItem!.imageShape = .Poster
            
            items.append(contentItem!)
        }
        
        print(items)
        
        return items
    }

}

class LegoVideo
{
    let id: String
    let thumbnailUrl: NSURL
    let title: String
    
    init(json: NSDictionary)
    {
        id = json["Id"] as! String
        thumbnailUrl = tryGetUrl(json, key: "ThumbnailUri")!
        title = json["Title"] as! String
    }
}

public func tryGetUrl(dictionary: NSDictionary, key: String) -> NSURL?
{
    if let value = dictionary[key] as? String, let url = NSURL(string: value)
    {
        return url
    }
    
    return nil
}