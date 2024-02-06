//
//  ViewController.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import UIKit

class SummaryViewController: UIViewController {

    private struct Section {
        let activities: [ActivityPresentable]
        let title: String
    }

    // A simple way of managing what state a VC is in
    // Can be exapnded to add `loading` etc that would show a spinner
    // if data is being loaded etc
    private enum State {
        case normal, empty
    }

    private let collectionViewLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let cellSize = sectionIndex == 0 ? CGSize(width: 0.5, height: 82) : CGSize(width: 1, height: 80)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(cellSize.width),
                heightDimension: .absolute(cellSize.height)
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(cellSize.height)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(46)
            )
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [headerItem]

            return section
        }

        return layout
    }()

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var noDataLabel: UILabel!

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.white.cgColor, UIColor.veryLightGray.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0.6, 1]
        return layer
    }()

    private var healthKitManager = HealthKitManager.shared
    private var sections: [Section] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private var state: State = .normal

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(SummaryCollectionViewCell.self, forCellWithReuseIdentifier: SummaryCollectionViewCell.identifier)
        self.collectionView.register(ActivityCollectionViewCell.self, forCellWithReuseIdentifier: ActivityCollectionViewCell.identifier)
        self.collectionView.register(TitleCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleCollectionViewHeader.identifier)
        self.collectionView.collectionViewLayout = self.collectionViewLayout

        self.view.layer.insertSublayer(self.gradientLayer, at: 0)
        self.fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.view.bounds
    }

    private func layout(for state: State) {
        self.state = state

        switch state {
        case .normal:
            self.collectionView.isHidden = false
            self.noDataLabel.isHidden = true
        case .empty:
            self.collectionView.isHidden = true
            self.noDataLabel.isHidden = false
        }
    }
}

extension SummaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension SummaryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 && self.sections[1].activities.isEmpty {
            return 1
        }

        return self.sections[section].activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCollectionViewCell.identifier, for: indexPath) as! SummaryCollectionViewCell
            cell.configure(for: section.activities[indexPath.item])
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCollectionViewCell.identifier, for: indexPath) as! ActivityCollectionViewCell
        if section.activities.isEmpty {
            cell.configureForEmpty()
        } else {
            cell.configure(for: section.activities[indexPath.item])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleCollectionViewHeader.identifier, for: indexPath) as! TitleCollectionViewHeader
        header.configure(for: self.sections[indexPath.section].title)
        return header
    }
}

extension SummaryViewController {

    // This method would ideally sit elsewhere with a centralized data fetcher.
    // Also the mapping to user representable types should be done elsewhere
    // for example in a VM or something similar
    private func fetchData() {
        Task {
            do {
                try await self.healthKitManager.requestAuthorization()

                let workouts = try await self.healthKitManager.fetchWorkouts()
                // We set the kcal, elevation and distance as optionals since we don't need them
                // however they intentionally throw an error if they don't fetch successfully
                // so that in other cases we get the context if we need it
                let totalCalories = (try? await self.healthKitManager.fetchTotalActiveEnergyBurned()) ?? 0
                let totalElevation = (try? await self.healthKitManager.fetchTotalElevationGain()) ?? 0
                let totalDistance = (try? await self.healthKitManager.fetchTotalDistance()) ?? 0

                // Sum up all of the workout durations
                let totalDuration = workouts.reduce(0) { $0 + $1.duration }
                let activities = [
                    ActivitySummary(duration: totalDuration),
                    ActivitySummary(calories: totalCalories),
                    ActivitySummary(distance: totalDistance),
                    ActivitySummary(elevationGain: totalElevation)
                ]
                let summarySection = Section(activities: activities, title: "Running 30 days")

                let title = workouts.count == 1 ? "1 Activity" : "\(workouts.count) Activities"
                let activitiesSection = Section(activities: workouts, title: title)

                await MainActor.run {
                    self.sections = [summarySection, activitiesSection]
                    self.layout(for: .normal)
                }
            } catch {
                self.layout(for: .empty)

                UIApplication.shared.showAlert(error: error) { shouldRetry in
                    if shouldRetry {
                        self.fetchData()
                    }
                }
            }
        }
    }
}
