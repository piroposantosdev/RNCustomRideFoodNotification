# React Native Custom Ride/Food Notification

A native plugin for React Native to display customizable Live Activities (iOS) and Custom Notifications (Android) for Ride-Sharing and Food Delivery apps.

## Features

- **Ride Mode (Uber-style)**:
  - Driver/Car info.
  - Progress bar with moving car icon.
  - Status updates (e.g., "Dropoff at 17:06").
- **Food Mode (iFood-style)**:
  - Delivery estimate.
  - Segmented progress bar.
  - Status updates (e.g., "Preparing order").
- **Fully Customizable**:
  - Colors, Icons, Texts, Progress.
  - Dynamic updates via React Native bridge.

## Installation

This project is currently set up as an example app with the plugin code embedded.

### iOS Setup (Detailed Step-by-Step)

To enable Live Activities, you must add a Widget Extension to your iOS project. Follow these steps carefully:

1.  **Open the Project in Xcode**:
    - Navigate to the `ios` folder in your terminal.
    - Run `xed .` or open `RNCustomRideFoodNotification.xcworkspace` manually.

2.  **Create the Widget Target**:
    - In Xcode, go to **File > New > Target...**.
    - Search for **Widget Extension** and select it. Click **Next**.
    - **Product Name**: Enter `RideFoodWidget`.
    - **Include Live Activity**: Check this box.
    - **Include Configuration App Intent**: Uncheck this (we don't need it for this example).
    - Click **Finish**.
    - If asked about "Activate scheme", click **Activate**.

3.  **Add Source Files to the Widget Target**:
    - I have already moved the files to the `ios/RideFoodWidget/` folder:
        - `RideFoodActivityAttributes.swift`
        - `RideFoodActivityWidget.swift`
    - **In Xcode**, right-click on the `RideFoodWidget` folder (in the Project Navigator) and select **"Add Files to 'RNCustomRideFoodNotification'..."**.
    - Select the two files mentioned above.
    - **Crucial Step**:
        - Select `RideFoodActivityAttributes.swift` in the Project Navigator.
        - Open the **Right Sidebar** (Inspectors) in Xcode.
        - Click on the **File Inspector** icon (looks like a sheet of paper with a folded corner).
        - Under the **Target Membership** section, ensure **BOTH** `RNCustomRideFoodNotification` (your app) **AND** `RideFoodWidget` (your extension) are checked.
        - Select `RideFoodActivityWidget.swift`. Ensure **ONLY** `RideFoodWidget` is checked.

4.  **Clean Up**:
    - I have already updated `RideFoodWidgetBundle.swift` and removed the template files for you.

5.  **Configure Info.plist**:
    - Open your main app's `Info.plist` (inside `RNCustomRideFoodNotification` folder).
    - Add a new key: `NSSupportsLiveActivities` and set it to `YES` (Boolean).

6.  **Run the App**:
    - Select your main app scheme (`RNCustomRideFoodNotification`) in the top toolbar.
    - Select a simulator that supports Dynamic Island (e.g., iPhone 14 Pro, iPhone 15/16).
    - Run the app (Cmd+R).

### Android Setup

1.  **Permissions**:
    - For Android 13+ (API 33+), you need to request `POST_NOTIFICATIONS` permission at runtime. This example assumes you handle permissions or test on an emulator where you can grant them.

2.  **Layouts**:
    - The custom layouts are located in `android/app/src/main/res/layout/`.
    - `notification_ride.xml`
    - `notification_food.xml`

## Usage

Import the library in your React Native code:

```typescript
import { RideFoodNotification } from './src/RideFoodNotification';
```

### Start an Activity

```typescript
const activityId = await RideFoodNotification.start('ride', {}, {
  statusTitle: 'Dropoff at 17:06',
  statusDescription: 'Heading to Destination',
  progress: 0.5, // 0.0 to 1.0
  estimatedTime: '17:06',
  driverOrRestaurantName: 'Uber',
  iconName: 'car',
  primaryColorHex: '#FFFFFF',
});
```

### Update an Activity

```typescript
await RideFoodNotification.update(activityId, {
  statusTitle: 'Arriving soon',
  statusDescription: '2 mins away',
  progress: 0.8,
  estimatedTime: '17:08',
  driverOrRestaurantName: 'Uber',
  iconName: 'car',
  primaryColorHex: '#FFFFFF',
});
```

### End an Activity

```typescript
await RideFoodNotification.end(activityId);
```

## Customization

You can customize the following properties in the `contentState`:

- `statusTitle`: Main status text.
- `statusDescription`: Subtitle or description.
- `progress`: Float between 0.0 and 1.0.
- `estimatedTime`: Time string displayed prominently.
- `primaryColorHex`: Hex color code for progress bars and icons.

### Icon Customization

You can dynamically change the icon displayed in the Live Activity by passing the `iconName` property.

**1. Using SF Symbols (Built-in):**
Pass the name of any SF Symbol.
- Examples: `'car.fill'`, `'car.side.fill'`, `'bus.fill'`, `'bicycle'`, `'figure.walk'`.

**2. Using Custom Images (Assets):**
You can use your own custom images (PNG, PDF, etc.).

1.  Open your project in Xcode.
2.  Navigate to the `RideFoodWidget` folder.
3.  Open `Assets.xcassets`.
4.  Drag and drop your image file into the asset catalog.
5.  Rename the asset to something simple (e.g., `custom_car`).
6.  In your React Native code, pass this name: `iconName: 'custom_car'`.

*Note: The widget will first look for a custom asset with the given name. If not found, it will attempt to load it as an SF Symbol.*

## License

MIT
