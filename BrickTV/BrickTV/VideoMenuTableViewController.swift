//
//  VideoMenuTableViewController.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 20/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import UIKit

class VideoMenuTableViewController: UITableViewController
{
    var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = theme.title
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theme.videos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoMenuCell") as! VideoMenuCell
        cell.video = theme.videos[indexPath.row]
        return cell
    }
}

class VideoMenuCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    
    var video: Video? {
        didSet {
            titleLabel.text = video!.title
        }
    }
}