//
//  HBTools.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/26.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView ...)  {
        for v in views {
            addSubview(v)
        }
    }
}

func MAX<T: Comparable>(_ a: T, _ b: T) -> T {
    return a < b ? b : a
}

func MIN<T: Comparable>(_ a: T, _ b: T) -> T {
    return a < b ? a : b
}

