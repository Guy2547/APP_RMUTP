import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function AttendanceScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Card style={styles.checkinCard}>
        <View style={styles.qrContainer}>
          <Text style={styles.qrIcon}>◧</Text>
        </View>
        <Text style={styles.courseInfo}>ENGCE302 • รหัสห้อง <Text style={styles.roomCode}>DB-0921</Text></Text>
        <Text style={styles.timeInfo}>ห้องเปิด 09:00–09:15 • เหลือ 07:32 นาที</Text>
        <TouchableOpacity style={styles.checkinBtn}>
          <Text style={styles.checkinBtnText}>กดเช็คชื่อ / สแกน QR</Text>
        </TouchableOpacity>
      </Card>

      <Card style={styles.historyCard}>
        <Text style={styles.sectionTitle}>ประวัติสัปดาห์นี้</Text>
        <Text style={styles.historyText}>มา 4 • สาย 1 • ขาด 0 (92%)</Text>
      </Card>
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
  checkinCard: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 24,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 4,
  },
  qrContainer: {
    width: 120,
    height: 120,
    borderRadius: 20,
    backgroundColor: '#420671',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  qrIcon: {
    fontSize: 56,
  },
  courseInfo: {
    fontSize: 14,
    fontWeight: '600',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  roomCode: {
    color: '#652D91',
  },
  timeInfo: {
    fontSize: 12,
    color: '#652D91',
    fontFamily: 'Kanit',
    marginBottom: 16,
  },
  checkinBtn: {
    width: '100%',
    backgroundColor: '#420671',
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
  },
  checkinBtnText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
  historyCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 18,
    marginTop: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 8,
  },
  historyText: {
    fontSize: 13,
    color: '#652D91',
    fontFamily: 'Kanit',
  },
});
