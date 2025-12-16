# React Native Custom Ride/Food Notification

A native plugin for React Native to display customizable Live Activities (iOS) and Custom Notifications (Android) for Ride-Sharing and Food Delivery apps.

## Installation

```sh
npm install rn-custom-ride-food-notification
```

## iOS Setup

### 1. Install Pods
```sh
cd ios && pod install
```

### 2. Add Widget Extension (Required for Live Activities)
Live Activities require a Widget Extension target in your iOS project.

1.  Open your project in Xcode (`xed ios`).
2.  Go to **File > New > Target...**.
3.  Select **Widget Extension**.
4.  Name it (e.g., `RideFoodWidget`) and ensure **Include Live Activity** is checked.
5.  Uncheck "Include Configuration App Intent".

### 3. Add Widget Code
Since the UI for the Live Activity must live in your app's extension, you need to copy the Swift UI code.

**Option A: Copy from this library**
Copy the contents of `RideFoodActivityWidget.swift` and `RideFoodActivityAttributes.swift` from `node_modules/rn-custom-ride-food-notification/ios/` to your new Widget Extension folder.

**Option B: Use your own UI**
You can implement your own UI using the `RideFoodActivityAttributes` struct. Ensure the struct matches the one expected by the library.

### 4. Configure Info.plist
Add `NSSupportsLiveActivities` to your main app's `Info.plist` and set it to `YES`.

## Android Setup

1.  **Permissions**: Request `POST_NOTIFICATIONS` permission at runtime (Android 13+).
2.  **Layouts**: Copy the layout files (`notification_ride.xml`, `notification_food.xml`) from `node_modules/rn-custom-ride-food-notification/android/src/main/res/layout/` to your app's `android/app/src/main/res/layout/` folder.

## Usage

```typescript
import RideFoodNotification from 'rn-custom-ride-food-notification';

// Start Activity
const activityId = await RideFoodNotification.start('ride', {}, {
  statusTitle: 'Dropoff at 17:06',
  statusDescription: 'Heading to Destination',
  progress: 0.5,
  estimatedTime: '17:06',
  driverOrRestaurantName: 'Uber',
  iconName: 'car.fill',
  primaryColorHex: '#FFFFFF',
});

// Update
await RideFoodNotification.update(activityId, {
  progress: 0.8,
  estimatedTime: '17:08',
  // ... other fields
});

// End
await RideFoodNotification.end(activityId);
```

## Customization

- `iconName`: Pass any SF Symbol name (e.g., `car.fill`, `fork.knife`) OR the name of a custom image asset in your Widget Extension.
- `secondaryIconName`: Icon for the footer (e.g., establishment logo).
- `orderNumber`: Order ID to display in the footer.

## License

MIT
