//
//  TitleCollectionViewHeader.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 2. 02. 24.
//

import Foundation
import UIKit

// An example class of a reusable component. It's a very crude example at that though.
final class TitleCollectionViewHeader: UICollectionReusableView, IdentifiableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = .headerLabelTitle
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        self.addSubview(self.titleLabel)

        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

// It's not really a cell however the protocol works equally well
extension TitleCollectionViewHeader: ConfigurableCell {
    func configure(for item: String) {
        self.titleLabel.text = item.uppercased()
    }
}
