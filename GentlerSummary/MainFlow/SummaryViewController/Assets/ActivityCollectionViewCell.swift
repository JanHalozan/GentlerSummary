//
//  ActivityCollectionViewCell.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import UIKit

final class ActivityCollectionViewCell: UICollectionViewCell, IdentifiableView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(red: 130, green: 130, blue: 130, alpha: 0.85)
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
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .fill

        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.imageView.widthAnchor.constraint(equalToConstant: 35),
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        self.imageView.tintColor = self.titleLabel.textColor

        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 24
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowRadius = 30
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.contentView.layer.shadowOpacity = 0.08
        // This is default behaviour but we want to make it explicit
        self.contentView.layer.masksToBounds = false
        self.layer.masksToBounds = false
    }
}

extension ActivityCollectionViewCell: ConfigurableCell {
    func configure(for item: ActivityPresentable) {
        self.titleLabel.text = item.title
        self.subtitleLabel.text = item.subtitle
        self.imageView.image = item.icon
    }

    func configureForEmpty() {
        self.titleLabel.text = "No activities to show"
        self.subtitleLabel.text = nil
        self.imageView.image = nil
    }
}
