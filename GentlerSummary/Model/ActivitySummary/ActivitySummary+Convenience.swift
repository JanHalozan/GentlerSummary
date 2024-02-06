//
//  ActivitySummary+Convenience.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 2. 02. 24.
//

import Foundation
import UIKit

// Just convenience initializers
extension ActivitySummary {

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    init(calories: Double) {
        Self.numberFormatter.maximumFractionDigits = 0

        let subtitle: String
        let attributedSubtitle: NSAttributedString?

        if calories == 0 {
            subtitle = "-"
            attributedSubtitle = nil
        } else {
            let formattedKcal = Self.numberFormatter.string(from: calories as NSNumber) ?? ""
            let attributed = NSMutableAttributedString(string: "\(formattedKcal) kcal")
            attributed.addAttribute(.font, value: UIFont.roundedFont(ofSize: 14, weight: .semibold), range: NSRange(location: formattedKcal.count + 1, length: 4))
            subtitle = "\(formattedKcal) kcal"
            attributedSubtitle = attributed
        }

        self.init(title: "Active Energy", subtitle: subtitle, attributedSubtitle: attributedSubtitle)
    }

    init(duration: Double) {
        let subtitle: String
        let attributedSubtitle: NSAttributedString?

        if duration == 0 {
            subtitle = "-"
            attributedSubtitle = nil
        } else { // This should also support prettier formatting - no hours if it's sub 1 hour etc.
            let hours = "\(Int(duration) / 3600)"
            let minutes = "\((Int(duration) / 60) % 60)"
            let attributed = NSMutableAttributedString(string: "\(hours) hr \(minutes) min")

            attributed.addAttribute(.font, value: UIFont.roundedFont(ofSize: 14, weight: .semibold), range: NSRange(location: hours.count + 1, length: 2))
            attributed.addAttribute(.font, value: UIFont.roundedFont(ofSize: 14, weight: .semibold), range: NSRange(location: hours.count + minutes.count + 5, length: 3))

            subtitle = "\(hours) hr \(minutes) min"
            attributedSubtitle = attributed
        }

        self.init(title: "Duration", subtitle: subtitle, attributedSubtitle: attributedSubtitle)
    }

    // Formatting would ideally check for the distance and format
    // in meters, then kilometers, ...
    init(distance: Double) {
        Self.numberFormatter.maximumFractionDigits = 2

        let subtitle: String
        let attributedSubtitle: NSAttributedString?

        if distance == 0 {
            subtitle = "-"
            attributedSubtitle = nil
        } else {
            let formattedDistance = Self.numberFormatter.string(from: (distance / 1000) as NSNumber) ?? ""
            let attributed = NSMutableAttributedString(string: "\(formattedDistance) km")
            attributed.addAttribute(.font, value: UIFont.roundedFont(ofSize: 14, weight: .semibold), range: NSRange(location: formattedDistance.count + 1, length: 2))
            subtitle = "\(formattedDistance) km"
            attributedSubtitle = attributed
        }

        self.init(title: "Distance", subtitle: subtitle, attributedSubtitle: attributedSubtitle)
    }

    init(elevationGain: Double) {
        Self.numberFormatter.maximumFractionDigits = 2

        let subtitle: String
        let attributedSubtitle: NSAttributedString?

        if elevationGain == 0 {
            subtitle = "-"
            attributedSubtitle = nil
        } else {
            let formattedElevation = Self.numberFormatter.string(from: elevationGain as NSNumber) ?? ""
            let attributed = NSMutableAttributedString(string: "\(formattedElevation) m")
            attributed.addAttribute(.font, value: UIFont.roundedFont(ofSize: 14, weight: .semibold), range: NSRange(location: formattedElevation.count + 1, length: 1))
            subtitle = "\(formattedElevation) m"
            attributedSubtitle = attributed
        }

        self.init(title: "Elevation Gain", subtitle: subtitle, attributedSubtitle: attributedSubtitle)
    }
}
