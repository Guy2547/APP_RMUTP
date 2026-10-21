import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';

export default function TimetableScreen() {
  const days = ['จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์'];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>🗓️ ตารางเรียน — เทอม 1/2569</Text>
      </View>

      <View style={styles.daySelector}>
        {days.map((day) => (
          <TouchableOpacity key={day} style={[styles.dayBtn, styles.dayBtnActive]}>
            <Text style={styles.dayText}>{day}</Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.card}>
        <View style={styles.classItem}>
          <Text style={styles.classTime}>09:00–12:00</Text>
          <View style={styles.classInfo}>
            <Text style={styles.className}>ENGCE302 ระบบฐานข้อมูล</Text>
            <Text style={styles.classDetail}>ห้อง 1604 • อ.สุรชัย • เช็คชื่อแล้ว</Text>
          </View>
        </View>
        <View style={styles.classItem}>
          <Text style={styles.classTime}>13:00–16:00</Text>
          <View style={styles.classInfo}>
            <Text style={styles.className}>ENGCE305 เครือข่ายคอมพิวเตอร์</Text>
            <Text style={styles.classDetail}>Lab 1502 • ผศ.นภัส • เริ่มบ่ายนี้</Text>
          </View>
        </View>
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
  header: {
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  daySelector: {
    flexDirection: 'row',
    gap: 6,
    marginBottom: 16,
  },
  dayBtn: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#cbb9e6',
  },
  dayBtnActive: {
    backgroundColor: '#420671',
    borderColor: '#420671',
  },
  dayText: {
    fontSize: 12,
    color: '#420671',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 18,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 18,
    elevation: 4,
  },
  classItem: {
    flexDirection: 'row',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  classTime: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#652D91',
    width: 100,
    fontFamily: 'Kanit-Bold',
  },
  classInfo: {
    flex: 1,
  },
  className: {
    fontSize: 14,
    fontWeight: '600',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  classDetail: {
    fontSize: 12,
    color: '#652D91',
    fontFamily: 'Kanit',
    marginTop: 2,
  },
});
