import Foundation
import ActivityKit
import React

@objc(LiveActivityModule)
@available(iOS 16.2, *)
class LiveActivityModule: NSObject {
    
    @objc
    func start(
        _ type: String,
        attributesDict: NSDictionary,
        contentStateDict: NSDictionary,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            reject("not_enabled", "Live Activities are not enabled", nil)
            return
        }
        
        guard #available(iOS 16.2, *) else {
            reject("not_supported", "Live Activities require iOS 16.2+", nil)
            return
        }
        
        let attributes = RideFoodActivityAttributes(type: type)
        let contentState = mapContentState(contentStateDict)
        
        do {
            let activity = try Activity<RideFoodActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            resolve(activity.id)
        } catch {
            reject("start_error", "Failed to start activity: \(error.localizedDescription)", error)
        }
    }
    
    @objc
    func update(
        _ activityId: String,
        contentStateDict: NSDictionary,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 16.2, *) else {
            reject("not_supported", "Live Activities require iOS 16.2+", nil)
            return
        }
        
        Task {
            guard let activity = Activity<RideFoodActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
                reject("not_found", "Activity not found", nil)
                return
            }
            
            let contentState = mapContentState(contentStateDict)
            
            await activity.update(
                ActivityContent<RideFoodActivityAttributes.ContentState>(
                    state: contentState,
                    staleDate: nil
                )
            )
            resolve(nil)
        }
    }
    
    @objc
    func end(
        _ activityId: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 16.2, *) else {
            reject("not_supported", "Live Activities require iOS 16.2+", nil)
            return
        }
        
        Task {
            guard let activity = Activity<RideFoodActivityAttributes>.activities.first(where: { $0.id == activityId }) else {
                reject("not_found", "Activity not found", nil)
                return
            }
            
            await activity.end(nil, dismissalPolicy: .immediate)
            resolve(nil)
        }
    }
    
    private func mapContentState(_ dict: NSDictionary) -> RideFoodActivityAttributes.ContentState {
        return RideFoodActivityAttributes.ContentState(
            statusTitle: dict["statusTitle"] as? String ?? "",
            statusDescription: dict["statusDescription"] as? String ?? "",
            progress: dict["progress"] as? Double ?? 0.0,
            estimatedTime: dict["estimatedTime"] as? String ?? "",
            driverOrRestaurantName: dict["driverOrRestaurantName"] as? String ?? "",
            iconName: dict["iconName"] as? String ?? "",
            secondaryIconName: dict["secondaryIconName"] as? String ?? "",
            orderNumber: dict["orderNumber"] as? String ?? "",
            primaryColorHex: dict["primaryColorHex"] as? String ?? "#000000"
        )
    }
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
