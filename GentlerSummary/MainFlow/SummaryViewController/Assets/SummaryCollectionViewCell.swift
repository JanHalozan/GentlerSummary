//
//  SummaryCollectionViewCell.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import UIKit

final class SummaryCollectionViewCell: UICollectionViewCell, IdentifiableView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    private let dataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .roundedFont(ofSize: 22, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
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
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.dataLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .fill

        self.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        self.contentView.backgroundColor = .veryLightGray
        self.contentView.layer.cornerRadius = 24
    }
}

extension SummaryCollectionViewCell: ConfigurableCell {
    func configure(for item: ActivityPresentable) {
        self.titleLabel.text = item.title
        self.dataLabel.text = item.subtitle

        if let summary = item as? ActivitySummary, let attributedSubtitle = summary.attributedSubtitle {
            self.dataLabel.attributedText = attributedSubtitle
        }
    }
}
