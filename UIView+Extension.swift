//
//  UIView+Extension.swift
//  iOS7-HW12
//
//  Created by Anatoly Kurilik on 10.09.22.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
