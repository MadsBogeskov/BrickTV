//
//  ThemeViewController.swift
//  BrickTV
//
//  Created by Morten Bøgh on 19/10/2015.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class VideoCell: UICollectionViewCell {
    static let reuseIdentifier = "VideoCell"
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
        label.alpha = 0.0
    }
    
    // MARK: - UICollectionReusableView
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.alpha = 0.0
    }
    
    // MARK: - UIFocusEnvironment
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            if self.focused {
                self.label.alpha = 1.0
            }
            else {
                self.label.alpha = 0.0
            }
            }, completion: nil)
    }
    
    internal func populate(video: Video) {
        label.text = video.title
        imageView.image = video.thumbnailImage
        video.loadThumbnailImage() { [weak self] in
            if let wself = self
            {
                wself.imageView.image = video.thumbnailImage
            }
        }
    }
}

class ThemeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIVisualEffectView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var theme: Theme!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadingLabel.text = theme.title
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.35, delay: 0.3, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.loadingIndicator.alpha = 1
            }) { (finished) -> Void in
                self.theme.loadVideos({ (_) -> () in
                    self.collectionView.reloadData()
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        self.loadingView.alpha = 0
                    })
                })
        }
    }
}

// MARK: - Segue
extension ThemeViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let videoPlayerViewController = segue.destinationViewController as? VideoPlayerViewController, cell = sender as? VideoCell, indexPath = self.collectionView?.indexPathForCell(cell) {
            let video = theme.videos[indexPath.item]
            videoPlayerViewController.video = video
        }
        
        if let videoPlayerViewController = segue.destinationViewController as? VideoInfoViewController, cell = sender as? VideoCell, indexPath = self.collectionView?.indexPathForCell(cell) {
            let video = theme.videos[indexPath.item]
            videoPlayerViewController.video = video
        }
    }
}


// MARK: - UICollectionViewDataSource
extension ThemeViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theme.videos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(VideoCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? VideoCell else { fatalError("ahh ahh you didn't say the magic word!") }
        let video = theme.videos[indexPath.item]
        cell.populate(video)
    }
}

// MARK: - UICollectionViewDelegate
extension ThemeViewController: UICollectionViewDelegateFlowLayout {
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}