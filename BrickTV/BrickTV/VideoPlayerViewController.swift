//
//  VideoPlayerViewController.swift
//  BrickTV
//
//  Created by Morten Bøgh on 19/10/2015.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit
import AVKit



class VideoPlayerViewController: AVPlayerViewController {
    let url = "http://legoprod-f.akamaihd.net/i/s/public/66/f7/66f70008-c10a-40f4-9ebb-6f8ec95efd18_269465fe-d82f-41b2-9d79-a2ac00be92d3_en-us_3_,256,512,1024,1536,2560,.mp4.csmil/master.m3u8"

    override func viewDidLoad() {
        super.viewDidLoad()
        player = AVPlayer(URL: NSURL(string: url)!)
        player?.play()
    }

}
