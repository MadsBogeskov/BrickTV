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
    
    func populdate(video: Video) {
        
    }
}

class ThemeViewController: UIViewController {
    var theme: Theme!

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UICollectionViewDataSource
extension ThemeViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(VideoCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let _ = cell as? VideoCell else { fatalError("ahh ahh you didn't say the magic word!") }
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