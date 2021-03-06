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
    var observer: AnyObject? = nil
    
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
        if video.progress < video.lengthInSeconds {
            player?.seekToTime(CMTimeMakeWithSeconds(Double(video.progress), 1))
        }
        player?.play()
        
        registerViewOn(video)
        let timer = CMTimeMake(1,1)
        observer = player?.addPeriodicTimeObserverForInterval(timer, queue: dispatch_get_main_queue(), usingBlock: { (time) -> Void in
            registerProgressOn(self.video, progress: Int(CMTimeGetSeconds(time)))
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let observer = observer else {return}
        player?.removeTimeObserver(observer)
    }

}

