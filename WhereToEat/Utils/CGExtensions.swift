//
//  CGExtensions.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import CoreGraphics

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2,
                  y: center.y - size.height / 2,
                  width: size.width,
                  height: size.height)
    }
    
    func centered(with size: CGSize) -> CGRect {
        return CGRect(center: center, size: size)
    }
}

extension CGSize {
    func with(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func with(height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
}
