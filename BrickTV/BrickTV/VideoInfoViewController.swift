//
//  VideoInfoViewController.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 20/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class VideoInfoViewController: UIViewController {

    var video: Video?
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
        @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let video = video
        {
            backgroundImage.image = video.thumbnailImage
            videoImage.image = video.thumbnailImage
            descriptionLabel.text = video.videoDescription
            titleLabel.text = video.title
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let videoPlayerViewController = segue.destinationViewController as? VideoPlayerViewController {
            videoPlayerViewController.video = video
        }
    }
}
