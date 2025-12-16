import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
    `The package 'rn-custom-ride-food-notification' doesn't seem to be linked. Make sure: \n\n` +
    Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
    '- You rebuilt the app after installing the package\n' +
    '- You are not using Expo Go\n';

// On iOS, the module is LiveActivityModule
// On Android, the module is NotificationModule
const RideFoodNotificationModule = Platform.select({
    ios: NativeModules.LiveActivityModule,
    android: NativeModules.NotificationModule,
});

const RideFoodNotification = RideFoodNotificationModule
    ? RideFoodNotificationModule
    : new Proxy(
        {},
        {
            get() {
                throw new Error(LINKING_ERROR);
            },
        }
    );

export interface ContentState {
    statusTitle: string;
    statusDescription: string;
    progress: number;
    estimatedTime: string;
    driverOrRestaurantName: string;
    iconName: string;
    secondaryIconName?: string;
    orderNumber?: string;
    primaryColorHex: string;
}

export interface RideFoodNotificationType {
    start(
        type: 'ride' | 'food',
        attributes: Record<string, any>,
        contentState: ContentState
    ): Promise<string>;

    update(
        activityId: string,
        contentState: ContentState
    ): Promise<void>;

    end(activityId: string): Promise<void>;
}

export default RideFoodNotification as RideFoodNotificationType;
