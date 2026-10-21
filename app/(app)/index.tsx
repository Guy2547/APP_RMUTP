import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';

export default function HomeScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.card}>
        <Text style={styles.cardTitle}>สวัสดี 👋</Text>
        <Text style={styles.cardSub}>ยินดีต้อนรับสู่ RMUTP Campus App</Text>
      </View>

      <View style={styles.grid}>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>🗓️</Text>
          <Text style={styles.gridLabel}>ตารางเรียน</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>📚</Text>
          <Text style={styles.gridLabel}>รายวิชา</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>🎓</Text>
          <Text style={styles.gridLabel}>เกรด</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>📢</Text>
          <Text style={styles.gridLabel}>ข่าว</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>✅</Text>
          <Text style={styles.gridLabel}>เช็คชื่อ</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.gridItem}>
          <Text style={styles.gridIcon}>🔔</Text>
          <Text style={styles.gridLabel}>แจ้งเตือน</Text>
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
  card: {
    backgroundColor: '#fff',
    borderRadius: 18,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 18,
    elevation: 4,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  cardSub: {
    fontSize: 13,
    color: '#652D91',
    fontFamily: 'Kanit',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  gridItem: {
    width: '32%',
    alignItems: 'center',
    paddingVertical: 10,
    backgroundColor: '#fff',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#cbb9e6',
  },
  gridIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  gridLabel: {
    fontSize: 10,
    color: '#420671',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
    textAlign: 'center',
  },
});
