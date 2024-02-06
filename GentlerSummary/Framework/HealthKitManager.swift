//
//  HealthKitManager.swift
//  GentlerSummary
//
//  Created by Jan Halozan on 31. 01. 24.
//

import Foundation
import HealthKit

final class HealthKitManager {

    enum Error: Swift.Error {
        case notAvailable, notAuthorized
    }

    public static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private let typeIdentifiers: [HKQuantityTypeIdentifier] = [.appleMoveTime, .activeEnergyBurned, .distanceWalkingRunning, .flightsClimbed]
    private let additonalTypes: [HKObjectType] = [.workoutType()]

    private var endDate: Date { .now }

    private var startDate: Date {
        let interval: TimeInterval = 60 * 60 * 24 * 30 // 30 days
        return self.endDate.addingTimeInterval(-interval)
    }

    func requestAuthorization() async throws {
        let types = self.typeIdentifiers.compactMap { HKObjectType.quantityType(forIdentifier: $0) } + self.additonalTypes

        return try await withCheckedThrowingContinuation { continuation in
            self.healthStore.requestAuthorization(toShare: [], read: Set(types)) { success, error in
                guard success else {
                    let err = error ?? Error.notAuthorized
                    return continuation.resume(throwing: err)
                }

                continuation.resume(returning: ())
            }
        }
    }

    func fetchWorkouts() async throws -> [HKWorkout] {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkout], Swift.Error>) in
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: .strictStartDate)

            let query = HKSampleQuery(sampleType: .workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { (query, samples, error) in
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(throwing: error ?? Error.notAvailable)
                    return
                }

                continuation.resume(returning: workouts)
            }

            self.healthStore.execute(query)
        }
    }

    func fetchTotalActiveEnergyBurned() async throws -> Double {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw Error.notAvailable
        }

        return try await self.fetchStatisticsQuery(quantityType: energyType).doubleValue(for: .kilocalorie())
    }

    func fetchTotalDistance() async throws -> Double {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw Error.notAvailable
        }

        return try await self.fetchStatisticsQuery(quantityType: distanceType).doubleValue(for: .meterUnit(with: .kilo))
    }

    func fetchTotalElevationGain() async throws -> Double {
        guard let elevationType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            throw Error.notAvailable
        }

        return try await self.fetchStatisticsQuery(quantityType: elevationType).doubleValue(for: .count())
    }

    private func fetchStatisticsQuery(quantityType: HKQuantityType) async throws -> HKQuantity {
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let quantity = result?.sumQuantity() else {
                    return continuation.resume(throwing: error ?? Error.notAvailable)
                }

                return continuation.resume(returning: quantity)
            }
            self.healthStore.execute(query)
        }
    }
}
