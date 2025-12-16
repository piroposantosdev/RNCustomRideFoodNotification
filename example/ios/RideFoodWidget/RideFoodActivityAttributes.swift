import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
public struct RideFoodActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state
        var statusTitle: String
        var statusDescription: String
        var progress: Double // 0.0 to 1.0
        var estimatedTime: String // "17:06" or "19:46 - 19:56"
        var driverOrRestaurantName: String
        var iconName: String // SystemImage or Asset name
        var secondaryIconName: String // Establishment icon
        var orderNumber: String
        var primaryColorHex: String
    }

    // Static data
    var type: String // "ride" or "food"
}
