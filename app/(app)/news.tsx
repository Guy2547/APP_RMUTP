import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function NewsScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>📢 ข่าว / ทุน / ฝึกงาน</Text>

      <View style={styles.chipRow}>
        <Chip label="ทั้งหมด" active />
        <Chip label="ทุน" />
        <Chip label="ฝึกงาน" />
        <Chip label="กิจกรรม" />
      </View>

      <NewsItem
        type="ทุน"
        title="ทุนเรียนดีคณะวิศวฯ 5,000 บาท (20 ทุน)"
        date="ปิดรับ 30 ก.ย."
        detail="GPA ≥ 3.00 • แนบทรานสคริปต์ • สมัครออนไลน์"
        color="#f59e0b"
        borderColor="#e9d27a"
        bgColor="#fffdf0"
      />

      <NewsItem
        type="ฝึกงาน"
        title="รับสหกิจ IT 10 อัตรา — สมัครด่วน"
        org="Toyota Tsusho"
        date="สัมภาษณ์ 5 ต.ค."
        detail="ที่ศูนย์สหกิจ"
        color="#652D91"
      />

      <NewsItem
        type="กิจกรรม"
        title="RMUTP Freshmen Day + ชมรมหุ่นยนต์"
        date="27 ก.ย."
        detail=""
        color="#64748b"
        borderLeftOnly
      />
    </ScrollView>
  );
}

function Chip({ label, active }: { label: string; active?: boolean }) {
  return (
    <View style={[styles.chip, active && styles.chipActive]}>
      <Text style={[styles.chipText, active && styles.chipTextActive]}>{label}</Text>
    </View>
  );
}

function NewsItem({ type, title, date, detail, color, borderColor, bgColor, borderLeftOnly }: any) {
  return (
    <TouchableOpacity style={[styles.newsItem, !borderLeftOnly && { borderColor }, { backgroundColor: bgColor }]}>
      <View style={styles.newsHeader}>
        <Text style={[styles.typeLabel, { color }]}>{type} • {date}</Text>
      </View>
      <Text style={styles.newsTitle}>{title}</Text>
      {org && <Text style={styles.newsOrg}>{org}</Text>}
      {detail && <Text style={styles.newsDetail}>{detail}</Text>}
    </TouchableOpacity>
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
  chipRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 16,
  },
  chip: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#cbb9e6',
  },
  chipActive: {
    backgroundColor: '#420671',
    borderColor: '#420671',
  },
  chipText: {
    fontSize: 11,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
  chipTextActive: {
    color: '#fff',
  },
  newsItem: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#cbb9e6',
    borderLeftWidth: borderLeftOnly ? 4 : 1,
  },
  newsHeader: {
    flexDirection: 'row',
    marginBottom: 6,
  },
  typeLabel: {
    fontSize: 10,
    fontWeight: '700',
    fontFamily: 'Kanit-Bold',
  },
  newsTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  newsOrg: {
    fontSize: 12,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  newsDetail: {
    fontSize: 11,
    color: '#64748b',
    fontFamily: 'Kanit',
  },
});
