//
//  UIFont+Extensions.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import UIKit

extension UIFont {
    static func roundedFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else {
            return systemFont
        }
        return UIFont(descriptor: descriptor, size: fontSize)
    }
}
