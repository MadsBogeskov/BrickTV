//
//  RecentlyWatchedViewController.swift
//  BrickTV
//
//  Created by Morten Bøgh on 20/10/2015.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class RecentlyWatchedViewController: UICollectionViewController {
    var videos = [Video]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadstuffz()
    }
    
    // curl 'https://services.videouserdata.lego.com/api/v1/views/?limit=100&csrfToken=c372946f-e963-41ea-9717-d36653993e01'
    // -H 'Pragma: no-cache'
    // -H 'Accept-Encoding: gzip, deflate, sdch'
    // -H 'Accept-Language: en-US,en;q=0.8'
    // -H 'csrfToken: c372946f-e963-41ea-9717-d36653993e01'
    // -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.71 Safari/537.36'
    // -H 'Accept: */*'
    // -H 'Cache-Control: no-cache'
    // -H 'X-Requested-With: XMLHttpRequest'
    // -H 'Cookie: PROMARKETPREF=da-DK; MARKETPREF=da-DK; X-Node-ABC=LEW-A01; .ASPXAUTH=89D29DA57F484D3BEAE72FDBC070FE096807CD97FADE9851457C2A3F57380EEDDBB7530F98C5D19CCB9DB6015DF0504C6FE3BF8DA740B62D59C4834A76DFF00DEFF99B227B9332171ADBB29DC0E61FF94EFCAC9DB0C715F45E6467F52A8DB88EF0B4B3B75DB39BFDDD7DA874D9A84055F998AAA345D481E9D9718DDF4FCE67C543835A797490DE4F89A20298DB72CC0BB858938858383B0194D7761285EBA448C2F69733; L.S.4=c372946f-e963-41ea-9717-d36653993e01; s_pers=%20s_fid%3D1EDEAF413B331DF1-2BB30A14B86418C0%7C1508481782420%3B%20c_dl%3D1%7C1445325182422%3B; s_sess=%20s_cc%3Dtrue%3B%20s_clientPerformance_persist%3Daccount2%253Ahomepage%253Asignin%257C1-3%3B%20s_sq%3D%3B; s_vi=[CS]v1|2AE98CA78530AD6B-60000301A005E284[CE]; X-Node-E=LUW-E04; X-LB=USALUL-A01-A02; L.S=c372946f-e963-41ea-9717-d36653993e01'
    // -H 'Connection: keep-alive'
    // -H 'Referer: https://services.videouserdata.lego.com/test?lidreload=1445323382433' --compressed
    
    // {"Views":[{"ObjectId":"035d056c-d4b5-4c1f-8429-0574747b3744"},{"ObjectId":"477f564f-f442-401a-9f69-01cc46113087"},{"ObjectId":"fbcd2639-a05d-43dc-9fe8-057a1663f6ea"},{"ObjectId":"ca7d4068-3120-4f1d-91e9-0791ab8670c4"},{"ObjectId":"0b91ab4a-a618-4145-a53c-beb541162fb8"}]}
    func loadstuffz() {
        let UrlString = "https://services.videouserdata.lego.com/api/v1/views/?limit=100&csrfToken=\(csrfToken)"
        let url = NSURL(string: UrlString)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue(csrfToken, forHTTPHeaderField: "csrfToken")
        request.addValue(cookie, forHTTPHeaderField: "Cookie")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("0", forHTTPHeaderField: "Content-Length")
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            print(NSString(data: data!, encoding: 4), response, error)
            guard let data = data else {
                return
            }
            
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
                return
            }
            
            guard let items = json["Views"] as? NSArray else {
                return
            }
            var requests: [NSMutableURLRequest] = []
            for item in (items as? [NSDictionary])!
            {
                let id = item["ObjectId"] as! String
                
                let trimmedId = id.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "{}"))
                
                guard let url = NSURL(string: "https://wwwsecure.lego.com/en-US/mediaplayer/api/video.json/\(trimmedId)") else {
                    continue
                }
                
                requests.append(NSMutableURLRequest(URL: url))//createURL("Video", resourceId: trimmedId)))
            }
            
            doLotsOfRequests(requests, createObject: { (dic) -> Video? in
                print("COUNT ME IN")
                if dic["Video"] === NSNull() { print("NULLL"); return nil }
                return Video(json: dic)
                }, completionHandler: { (objs) -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.videos = objs.reverse()
                        self.collectionView?.reloadData()
                    })
            })
        }).resume()
    }
}

// MARK: - Segue
extension RecentlyWatchedViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let videoPlayerViewController = segue.destinationViewController as? VideoPlayerViewController, cell = sender as? VideoCell, indexPath = self.collectionView?.indexPathForCell(cell) {
            let video = videos[indexPath.item]
            videoPlayerViewController.video = video
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RecentlyWatchedViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(VideoCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? VideoCell else { fatalError("ahh ahh you didn't say the magic word!") }
        let video = videos[indexPath.item]
        cell.populate(video)
    }
}

// MARK: - UICollectionViewDelegate
extension RecentlyWatchedViewController {
    override func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}