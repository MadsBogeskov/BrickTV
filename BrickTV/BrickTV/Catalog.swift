//
//  Catalog.swift
//  BrickTV
//
//  Created by Mads Bøgeskov on 19/10/15.
//  Copyright © 2015 LEGO. All rights reserved.
//

import Foundation

class Catalog
{
    func themes(completionHandler: ([Theme] -> ()))
    {
        let themeIds = ["E538AAB8-9193-445C-8F1F-3BC0DB8D39EB", "AE537D16-848C-47D1-9C28-5A57AEA1D87B", "60F0CE73-FFB1-4F26-AA2A-1AD9A5378A0B", "B05C9D06-FB83-42E4-A3C8-3F3DFCCD4D10", "2E9DDC10-6450-4F69-B757-ADDA9FA9A58F", "E2899F48-618A-4C00-9C19-57C29C0301D3", "48C07DFA-454B-4D24-82BE-599B1F67C4DC"];
        
        let r = themeIds.map {
            return NSMutableURLRequest(URL: createURL("theme", resourceId: $0))
        }
        
        doLotsOfRequests(r, createObject: { (dic) -> Theme in
            Theme(json: dic)
            }) { (themes) -> () in
                completionHandler(themes)
        }
    }
}

