//
//  ConfigurableCell.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import UIKit

protocol ConfigurableCell {
    associatedtype Item

    func configure(for item: Item)
}
