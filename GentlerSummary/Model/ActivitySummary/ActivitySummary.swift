//
//  Activity.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 1. 02. 24.
//

import Foundation
import UIKit
import HealthKit

// This protocol could be moved to a separate file as it's the "superprotocol" of the two presentable activity types
protocol ActivityPresentable {
    var title: String { get }
    var subtitle: String { get }
    var icon: UIImage? { get }
}

struct ActivitySummary: ActivityPresentable {
    let title: String
    var subtitle: String
    var attributedSubtitle: NSAttributedString?
    var icon: UIImage? { nil }
}

// Similarly this extension should probably be moved elsewhere as it's not directly a Model object
// However it has to do with the model in this example app which is why it's left here
extension HKWorkout: ActivityPresentable {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        return formatter
    }()

    var title: String {
        return self.workoutActivityType.title
    }

    var subtitle: String { Self.dateFormatter.string(from: self.startDate) }

    var icon: UIImage? {
        switch self.workoutActivityType {
        case .running: return UIImage(systemName: "figure.run")
        case .walking: return UIImage(systemName: "figure.walk")
        case .cycling: return UIImage(systemName: "figure.outdoor.cycle")
        case .swimming: return UIImage(systemName: "figure.pool.swim")
        default: return UIImage(systemName: "figure.strengthtraining.functional")
        }
    }
}

extension HKWorkoutActivityType {
    var title: String {
        switch self {
        case .walking: return "Outdoor Walk"
        case .running: return "Outdoor Run'"
        case .cycling: return "Outdoor Cycle"
        case .swimming: return "Pool Swim"
        default: return "Activity"
        }
    }
}
