//
//  LoadingViewController.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 20/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var action: ((UILabel, UIActivityIndicatorView) -> ())?
    
    override func viewDidLoad()
    {
        action!(titleLabel, spinner)
    }
}