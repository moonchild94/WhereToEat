//
//  UIExtensions.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 07.05.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    var width: CGFloat {
        return left + right
    }
    
    var height: CGFloat {
        return top + bottom
    }
}
