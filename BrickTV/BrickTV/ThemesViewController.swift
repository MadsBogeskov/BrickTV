//
//  ThemesViewController.swift
//  BrickTV
//
//  Created by Morten Bøgh on 19/10/2015.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

struct Theme {
    let name = "ThemeName"
    let image = UIImage(named: "theme_thumb")!
}

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
        label.text = theme.name
        imageView.image = theme.image
    }
}

class ThemesViewController: UICollectionViewController {
    let themes = [Theme(), Theme(), Theme(), Theme(), Theme(), Theme()]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
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
    
    override func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        guard let indexPaths = collectionView.indexPathsForSelectedItems() else { return true }
        return indexPaths.isEmpty
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let indexPath = collectionView.indexPathsForSelectedItems()?.first {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            return false
        } else {
            return true  
        }  
    }
}