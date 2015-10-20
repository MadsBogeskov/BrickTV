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
    var video: Video!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var adaptive: VideoFormat? = nil
        var mp4s = [VideoFormat]()
        for format in video.formats {
            if format.quality == VideoFormat.Quality.Adaptive && format.format == VideoFormat.Format.M3U8 {
                adaptive = format
            }
            else if format.format == VideoFormat.Format.Mp4 {
                mp4s.append(format)
            }
        }
        let url = (adaptive != nil) ? adaptive!.url : mp4s.first!.url
        
        player = AVPlayer(URL: url)
        player?.play()
        
        registerViewOn(video)
    }

}

