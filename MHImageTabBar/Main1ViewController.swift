//
//  Main1ViewController.swift
//  MHImageTabBar
//
//  Created by Mohamed Mohamed on 16/10/15.
//  Copyright © 2015 MHO. All rights reserved.
//

import UIKit

class Main1ViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            mhTabBarViewController?.setTabBarVisible(true, animated: true)
        } else {
            mhTabBarViewController?.setTabBarVisible(false, animated: true)
        }
    }
}
