import { NativeModules, Platform } from 'react-native';

const { LiveActivityModule, NotificationModule } = NativeModules;

export type ActivityType = 'ride' | 'food';

export interface ActivityContentState {
  statusTitle: string;
  statusDescription: string;
  progress: number; // 0.0 to 1.0
  estimatedTime: string;
  driverOrRestaurantName: string;
  iconName: string;
  primaryColorHex: string;
}

export const RideFoodNotification = {
  start: async (
    type: ActivityType,
    attributes: any = {}, // Static attributes
    contentState: ActivityContentState
  ): Promise<string> => {
    if (Platform.OS === 'ios') {
      return LiveActivityModule.start(type, attributes, contentState);
    } else {
      return NotificationModule.start(type, attributes, contentState);
    }
  },

  update: async (
    id: string,
    contentState: ActivityContentState
  ): Promise<void> => {
    if (Platform.OS === 'ios') {
      return LiveActivityModule.update(id, contentState);
    } else {
      return NotificationModule.update(id, contentState);
    }
  },

  end: async (id: string): Promise<void> => {
    if (Platform.OS === 'ios') {
      return LiveActivityModule.end(id);
    } else {
      return NotificationModule.end(id);
    }
  },
};
