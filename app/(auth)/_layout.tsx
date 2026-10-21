import { Stack } from 'expo-router';
import { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';

export default function AuthLayout() {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    setReady(true);
  }, []);

  if (!ready) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#420671" />
      </View>
    );
  }

  return (
    <Stack>
      <Stack.Screen options={{ headerShown: false }} />
    </Stack>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#420671',
  },
});
