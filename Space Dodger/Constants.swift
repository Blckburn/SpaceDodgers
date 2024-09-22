import Foundation
import CoreGraphics

struct Constants {
    static let meteorSpawnInterval: TimeInterval = 1.5
    static let fuelBonusInitialDelay: TimeInterval = 5.0
    static let fuelBonusSpawnIntervalRange: ClosedRange<TimeInterval> = 3.0...7.0
    static let scoreUpdateInterval: TimeInterval = 1.0
    static let fuelConsumptionInterval: TimeInterval = 1.0
    static let shipScale: CGFloat = 0.8
    static let blackHoleScale: CGFloat = 4.0
    // Добавь другие константы по необходимости
}
