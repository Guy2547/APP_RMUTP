import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';

export default function ProfileScreen() {
  const router = useRouter();

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.headerCard}>
        <View style={styles.avatar}>ม</View>
        <Text style={styles.name}>น.ส.มินตรา ใจดี</Text>
        <Text style={styles.id}>650602001 • วิศวกรรมคอมพิวเตอร์ ปี 2</Text>
      </View>

      <View style={styles.card}>
        <TouchableOpacity style={styles.menuItem} onPress={() => {}}>
          <Text style={styles.menuLabel}>👤 ข้อมูลส่วนตัว</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.menuItem} onPress={() => {}}>
          <Text style={styles.menuLabel}>🌐 ภาษา / Language</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.menuItem} onPress={() => {}}>
          <Text style={styles.menuLabel}>🔔 การแจ้งเตือน</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.menuItem} onPress={() => router.replace('/login')}>
          <Text style={styles.menuLogout}>🚪 ออกจากระบบ</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F3FA',
    padding: 16,
  },
  content: {
    paddingBottom: 80,
  },
  headerCard: {
    backgroundColor: '#420671',
    borderRadius: 24,
    padding: 24,
    alignItems: 'center',
    marginBottom: 16,
  },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#F6DC04',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  name: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  id: {
    fontSize: 12,
    color: '#F7E7BB',
    fontFamily: 'Kanit',
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 18,
    padding: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  menuLabel: {
    fontSize: 14,
    color: '#420671',
    fontFamily: 'Kanit',
    flex: 1,
  },
  menuLogout: {
    fontSize: 14,
    color: '#ff4d4d',
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
  },
});
