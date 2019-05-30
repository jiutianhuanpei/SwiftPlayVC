//
//  RootNaVC.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/30.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit

class RootNaVC: UINavigationController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
}
