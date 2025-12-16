import React, { useState } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  TextInput,
  ScrollView,
  Alert,
  Switch,
} from 'react-native';
import RideFoodNotification from 'rn-custom-ride-food-notification';

const App = () => {
  const [activityId, setActivityId] = useState<string | null>(null);
  const [type, setType] = useState<'ride' | 'food'>('ride');

  // Common State
  const [statusTitle, setStatusTitle] = useState('Dropoff at 17:06');
  const [statusDescription, setStatusDescription] = useState('Heading to Destination');
  const [progress, setProgress] = useState('0.5');
  const [estimatedTime, setEstimatedTime] = useState('17:06');
  const [primaryColorHex, setPrimaryColorHex] = useState('#000000');
  const [driverOrRestaurantName, setDriverOrRestaurantName] = useState('Uber');
  const [iconName, setIconName] = useState('car.fill');

  // New Fields
  const [secondaryIconName, setSecondaryIconName] = useState('building.2.crop.circle.fill');
  const [orderNumber, setOrderNumber] = useState('12345');

  const startActivity = async () => {
    try {
      const id = await RideFoodNotification.start(type, {}, {
        statusTitle,
        statusDescription,
        progress: parseFloat(progress),
        estimatedTime,
        driverOrRestaurantName,
        iconName,
        secondaryIconName, // New
        orderNumber,       // New
        primaryColorHex,
      });
      setActivityId(id);
      console.log('Activity Started:', id);
    } catch (error) {
      console.error('Error starting activity:', error);
      Alert.alert('Error', 'Failed to start activity');
    }
  };

  const updateActivity = async () => {
    if (!activityId) return;
    try {
      await RideFoodNotification.update(activityId, {
        statusTitle,
        statusDescription,
        progress: parseFloat(progress),
        estimatedTime,
        driverOrRestaurantName,
        iconName,
        secondaryIconName, // New
        orderNumber,       // New
        primaryColorHex,
      });
      console.log('Activity Updated');
    } catch (error) {
      console.error('Error updating activity:', error);
    }
  };

  const endActivity = async () => {
    if (!activityId) return;
    try {
      await RideFoodNotification.end(activityId);
      setActivityId(null);
      console.log('Activity Ended');
    } catch (error) {
      console.error('Error ending activity:', error);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.header}>Ride & Food Notification</Text>

        <View style={styles.typeSelector}>
          <TouchableOpacity
            style={[styles.typeButton, type === 'ride' && styles.activeType]}
            onPress={() => {
              setType('ride');
              setIconName('car.fill');
              setStatusTitle('Dropoff at 17:06');
            }}
          >
            <Text style={[styles.typeText, type === 'ride' && styles.activeTypeText]}>Ride</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.typeButton, type === 'food' && styles.activeType]}
            onPress={() => {
              setType('food');
              setIconName('fork.knife');
              setStatusTitle('Preparing order');
            }}
          >
            <Text style={[styles.typeText, type === 'food' && styles.activeTypeText]}>Food</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Status Title</Text>
          <TextInput style={styles.input} value={statusTitle} onChangeText={setStatusTitle} />

          <Text style={styles.label}>Description</Text>
          <TextInput style={styles.input} value={statusDescription} onChangeText={setStatusDescription} />

          <Text style={styles.label}>Progress (0.0 - 1.0)</Text>
          <TextInput style={styles.input} value={progress} onChangeText={setProgress} keyboardType="numeric" />

          <Text style={styles.label}>Time / Estimate</Text>
          <TextInput style={styles.input} value={estimatedTime} onChangeText={setEstimatedTime} />

          <Text style={styles.label}>Name (Driver/Restaurant)</Text>
          <TextInput style={styles.input} value={driverOrRestaurantName} onChangeText={setDriverOrRestaurantName} />

          <Text style={styles.label}>Primary Color (Hex)</Text>
          <TextInput style={styles.input} value={primaryColorHex} onChangeText={setPrimaryColorHex} />

          <Text style={styles.label}>Main Icon (SF Symbol or Asset)</Text>
          <View style={styles.iconSelector}>
            {['car.fill', 'car.side.fill', 'bus.fill', 'bicycle', 'figure.walk', 'fork.knife'].map((icon) => (
              <TouchableOpacity
                key={icon}
                style={[styles.iconButton, iconName === icon && styles.activeIconButton]}
                onPress={() => setIconName(icon)}
              >
                <Text style={styles.iconButtonText}>{icon}</Text>
              </TouchableOpacity>
            ))}
          </View>
          <TextInput
            style={[styles.input, { marginTop: 5 }]}
            value={iconName}
            onChangeText={setIconName}
            placeholder="Or type custom name..."
          />

          {type === 'food' && (
            <>
              <Text style={styles.label}>Footer: Establishment Icon</Text>
              <TextInput style={styles.input} value={secondaryIconName} onChangeText={setSecondaryIconName} />

              <Text style={styles.label}>Footer: Order Number</Text>
              <TextInput style={styles.input} value={orderNumber} onChangeText={setOrderNumber} />
            </>
          )}

        </View>

        <View style={styles.actionContainer}>
          <TouchableOpacity style={[styles.button, styles.startButton]} onPress={startActivity}>
            <Text style={styles.buttonText}>Start Activity</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.updateButton]} onPress={updateActivity}>
            <Text style={styles.buttonText}>Update</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.button, styles.endButton]} onPress={endActivity}>
            <Text style={styles.buttonText}>End Activity</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 20,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
    color: '#333',
  },
  typeSelector: {
    flexDirection: 'row',
    marginBottom: 20,
    backgroundColor: '#e0e0e0',
    borderRadius: 8,
    padding: 4,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 6,
  },
  activeType: {
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
    elevation: 2,
  },
  typeText: {
    fontWeight: '600',
    color: '#666',
  },
  activeTypeText: {
    color: '#000',
  },
  inputContainer: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 12,
    marginBottom: 20,
  },
  label: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
    marginTop: 10,
    fontWeight: '600',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 10,
    fontSize: 16,
    color: '#333',
    backgroundColor: '#fafafa',
  },
  iconSelector: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 5,
  },
  iconButton: {
    padding: 6,
    backgroundColor: '#eee',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'transparent',
  },
  activeIconButton: {
    borderColor: '#007AFF',
    backgroundColor: '#E3F2FD',
  },
  iconButtonText: {
    fontSize: 10,
  },
  actionContainer: {
    gap: 10,
  },
  button: {
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  startButton: {
    backgroundColor: '#007AFF',
  },
  updateButton: {
    backgroundColor: '#34C759',
  },
  endButton: {
    backgroundColor: '#FF3B30',
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default App;
