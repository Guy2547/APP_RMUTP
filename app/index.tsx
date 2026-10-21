import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { Text, View, ActivityIndicator, StyleSheet } from 'react-native';

export default function IndexScreen() {
  const router = useRouter();

  useEffect(() => {
    router.replace('/login');
  }, [router]);

  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color="#420671" />
      <Text style={styles.text}>กำลังโหลด...</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#420671',
  },
  text: {
    marginTop: 12,
    color: '#fff',
    fontSize: 14,
    fontFamily: 'Kanit',
  },
});
