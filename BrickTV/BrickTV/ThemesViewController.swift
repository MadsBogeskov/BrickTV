//
//  ThemesViewController.swift
//  BrickTV
//
//  Created by Morten Bøgh on 19/10/2015.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class ThemeCell: UICollectionViewCell {
    static let reuseIdentifier = "ThemeCell"
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
    
    func populate(theme: Theme) {
        label.text = theme.title
        imageView.image = theme.thumbnailImage
        theme.loadThumbnailImage() { [unowned self] in
            self.imageView.image = theme.thumbnailImage
        }
    }
}

class ThemesViewController: UICollectionViewController {
    var themes = [Theme]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        Catalog().themes { (themes) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.themes = themes
                self.collectionView?.reloadData()
            })
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ThemesViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(ThemeCell.reuseIdentifier, forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ThemeCell else { fatalError("ahh ahh you didn't say the magic word!") }
        let theme = themes[indexPath.item]
        cell.populate(theme)
    }
}

// MARK: - UICollectionViewDelegate
extension ThemesViewController {
    override func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }    
}