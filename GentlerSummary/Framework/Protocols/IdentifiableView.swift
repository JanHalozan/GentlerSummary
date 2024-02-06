//
//  IdentifiableView.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 2. 02. 24.
//

import Foundation
import UIKit

protocol IdentifiableView {
    static var identifier: String { get }
}

extension IdentifiableView where Self: UIView {
    static var identifier: String {
        String(describing: Self.self)
    }
}
