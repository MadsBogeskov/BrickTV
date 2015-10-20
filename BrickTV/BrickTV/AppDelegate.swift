//
//  AppDelegate.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var catalog: Catalog?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let string = url.absoluteString.stringByReplacingOccurrencesOfString("bricktv://id?", withString: "")
        
        let parts = string.componentsSeparatedByString("&name=")
        
        let videoId = parts.first
        let name = parts.last?.stringByRemovingPercentEncoding
        
        let loading = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoadingViewController") as! LoadingViewController
        loading.action = { titleLabel, spinner in
            
            titleLabel.text = name ?? "Loading"
            spinner.hidden = false
            spinner.startAnimating()
            
            
            guard let url = NSURL(string: "https://wwwsecure.lego.com/en-US/mediaplayer/api/video.json/\(videoId!)") else {
                loading.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            doLotsOfRequests([NSMutableURLRequest(URL: url)], createObject: { (dic) -> Video? in
                
                if let message = dic["Message"]
                {
                    let controller = UIAlertController(title: "Failed to open URL", message: message as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    controller.addAction(UIAlertAction(title: "🙀", style: UIAlertActionStyle.Default, handler: nil))
                    self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
                    return nil
                }
                
                return Video(json: dic)
                }, completionHandler: { (videos) -> () in
                    guard let video = videos.first else {
                        loading.dismissViewControllerAnimated(true, completion: nil)
                        return
                    }
                    
                    let videoPlayer = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("VideoInfoViewController") as! VideoInfoViewController
                    videoPlayer.video = video
                    video.loadThumbnailImage {
                        loading.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.window?.rootViewController?.presentViewController(videoPlayer, animated: true, completion: nil)
                        })
                    }
            })
        }
    
        self.window?.rootViewController?.presentViewController(loading, animated: true, completion: nil)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return true
    }
}

