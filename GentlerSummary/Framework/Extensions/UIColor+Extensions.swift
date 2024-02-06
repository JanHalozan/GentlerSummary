//
//  UIColor+Extensions.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import UIKit

extension UIColor {

    public static let headerLabelTitle = UIColor(red: 60, green: 60, blue: 67, alpha: 0.6)
    public static let veryLightGray = UIColor(red: 242, green: 242, blue: 247)

    /// Convenience initializer for creating a color with RGB components raging from 0 to 255. Alpha ranges from 0 to 1
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }

    /// Initialize a color with a 0xABCDEF pattern
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }

    /// in format '#XXXXXX` or `XXXXXX`
    convenience init?(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        guard cString.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255,
                  alpha: 1)
    }
}
