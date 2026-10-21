import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function NotifScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>🔔 แจ้งเตือน + ปฏิทิน</Text>

      <Card style={styles.notifCard}>
        <NotifItem color="#ef4444" title="HW6 ใกล้ครบกำหนด" detail="ENGCE302 — ส่งใน 2 วัน (23 ก.ย. 23:59)" />
        <NotifItem color="#f59e0b" title="ทุนคณะวิศวฯ ปิดรับ 30 ก.ย." detail="คุณสมบัติผ่าน กดสมัครได้เลย" />
        <NotifItem color="#652D91" title="เลื่อนห้อง ENGCE305 → Lab 1502" detail="จาก อ.นภัส เมื่อ 1 ชม.ก่อน" />
      </Card>

      <View style={styles.sectionTitle}>📅 ปฏิทินวิชาการ</View>
      <Card style={styles.calendarCard}>
        <CalendarItem date="23 ก.ย." text="หมดเขตส่ง HW6" />
        <CalendarItem date="30 ก.ย." text="ปิดรับทุน / ถอนรายวิชา" />
        <CalendarItem date="5 ต.ค." text="สัมภาษณ์สหกิจ" />
        <CalendarItem date="13–17 ต.ค." text="สอบกลางภาค" />
      </Card>
    </ScrollView>
  );
}

function NotifItem({ color, title, detail }: any) {
  return (
    <View style={styles.notifRow}>
      <View style={[styles.notifDot, { backgroundColor: color }]} />
      <View style={styles.notifText}>
        <Text style={styles.notifTitle}>{title}</Text>
        <Text style={styles.notifDetail}>{detail}</Text>
      </View>
    </View>
  );
}

function CalendarItem({ date, text }: any) {
  return (
    <View style={styles.calendarRow}>
      <Text style={styles.calendarDate}>{date}</Text>
      <Text style={styles.calendarText}>{text}</Text>
    </View>
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
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 12,
  },
  notifCard: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  notifRow: {
    flexDirection: 'row',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  notifDot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    marginTop: 8,
    marginRight: 10,
  },
  notifText: {
    flex: 1,
  },
  notifTitle: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  notifDetail: {
    fontSize: 11,
    color: '#64748b',
    fontFamily: 'Kanit',
    marginTop: 2,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginTop: 16,
    marginBottom: 10,
  },
  calendarCard: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  calendarRow: {
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  calendarDate: {
    fontSize: 12,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
    width: 70,
  },
  calendarText: {
    fontSize: 12,
    color: '#420671',
    fontFamily: 'Kanit',
  },
});
