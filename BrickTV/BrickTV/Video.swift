//
//  Video.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class Video: CustomStringConvertible {
    let id: String
    let videoFileId: String
    let title: String
    let key: String
    let themeThumbnailUrl: NSURL?
    let thumbnailProcessed: NSURL?
    let thumbnailUrl: NSURL?
    var thumbnailImage = UIImage(named: "ThemeThumbnailPlaceholder")!
    let videoDescription: String
    let imageLargeProcessed: NSURL?
    let formats: [VideoFormat]
    
    var progress: Int = 0
    var lengthInSeconds: Int
    
    init(json: NSDictionary)
    {
        let videoJson = json["Video"] as! NSDictionary
        
        id = (videoJson["Id"] as! String).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "{}"))
        videoFileId = videoJson["VideoFileId"] as! String
        title = videoJson["Title"] as! String
        
        if let lis = videoJson["LengthInSeconds"], s = lis.description, i = Int(s)
        {
            lengthInSeconds = i
        }
        else
        {
            lengthInSeconds = 0
        }
        
        key = videoJson["Key"] as! String
        themeThumbnailUrl = tryGetUrl(videoJson, key: "ThemeThumbnailUrl")
        thumbnailProcessed = tryGetUrl(videoJson, key: "ThumbnailProcessed")
        thumbnailUrl = tryGetUrl(videoJson, key: "ThumbnailUrl")
        
        videoDescription = videoJson["Description"] as? String ?? ""
        imageLargeProcessed = tryGetUrl(videoJson, key: "ImageLargeProcessed")
        
        if let videoFormatJson = json["VideoFormats"] as? NSArray
        {
            formats = videoFormatJson.map {
                VideoFormat(json: $0 as! NSDictionary)
            }
        }
        else
        {
            formats = []
        }
    }
    
    internal var description: String {
        get {
            return "id: \(id) -> title: \(title)"
        }
    }
    
//    func playableVideo(completionHandler: PlayableVideo? -> ())
//    {
//        guard let url = NSURL(string: "https://wwwsecure.lego.com/en-US/mediaplayer/api/video.json/\(id)") else {
//            return completionHandler(nil)
//        }
//        
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
//            guard let data = data, let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
//                return
//            }
//            
//            completionHandler(PlayableVideo(json: json as! NSDictionary))
//        }
//        
//        task.resume()
//    }
}

class VideoFormat
{
    enum Quality: String
    {
        case Adaptive = "Adaptive"
        case Lowest = "Lowest"
        case Low = "Low"
        case Medium = "Medium"
        case High = "High"
        case Highest = "Highest"
    }
    
    enum Format: String
    {
        case WebM = "WebM"
        case Mp4 = "Mp4"
        case F4M = "F4M"
        case M3U8 = "M3U8"
        case Unknown = ""
    }
    
    let url: NSURL
    let quality: Quality
    let format: Format
    
    init(json: NSDictionary)
    {
        url = tryGetUrl(json, key: "Url")!
        if let q = Quality(rawValue: json["Quality"] as! String)
        {
            quality = q
        }
        else
        {
            quality = Quality.Low
        }
        
        if let f = Format(rawValue: json["Format"] as! String)
        {
            format = f
        }
        else
        {
            format = Format.Unknown
        }
    }
}

extension Video {
    func loadThumbnailImage(completion: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            guard let thumbnailUrl = self.imageLargeProcessed where thumbnailUrl.absoluteString.characters.count > 0 else {
                completion()
                return
            }
            
            guard let data = NSData(contentsOfURL: thumbnailUrl) else {
                completion()
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion()
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.thumbnailImage = image
                completion()
            })
        }
    }
}