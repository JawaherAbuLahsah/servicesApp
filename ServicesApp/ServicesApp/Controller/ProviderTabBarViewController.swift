//
//  ProviderTabBarViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 01/06/1443 AH.
//

import UIKit

class ProviderTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        localizeTabBar()
        // Do any additional setup after loading the view.
    }
    
    func localizeTabBar() {
        tabBar.items?.enumerated().forEach{ (index, item)  in
            item.title = "\(index)tab".localizes
        }
    }

}
