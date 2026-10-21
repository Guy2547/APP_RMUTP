import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function GradesScreen() {
  const courses = [
    { code: 'ENGCE301', name: 'โครงสร้างข้อมูล', grade: 'A', points: 4.0, color: '#22c55e' },
    { code: 'ENGCE303', name: 'OS', grade: 'B+', points: 3.5, color: '#22c55e' },
    { code: 'GEN101', name: 'อังกฤษอาชีพ', grade: 'B', points: 3.0, color: '#420671' },
    { code: 'MATH201', name: 'สถิติวิศวะ', grade: 'C+', points: 2.5, color: '#f59e0b', warning: true },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Card style={styles.gpaCard}>
        <Text style={styles.gpaLabel}>GPA สะสม</Text>
        <Text style={styles.gpaValue}>3.42</Text>
        <Text style={styles.gpaSub}>เทอมนี้ 3.55 • หน่วยกิต 87/132</Text>
      </Card>

      <View style={styles.sectionTitle}>ผลการเรียน</View>

      {courses.map((c) => (
        <Card key={c.code} style={styles.courseCard}>
          <View style={styles.courseRow}>
            <Text style={styles.courseName}>{c.code} {c.name}</Text>
            <Text style={[styles.grade, c.warning && { color: '#f59e0b' }]}>
              {c.grade} ({c.points})
            </Text>
          </View>
        </Card>
      ))}

      <Card style={styles.tipCard}>
        <Text style={styles.tipText}>💡 เกรด C+ วิชาสถิติฉุด GPA — แนะนำลงติวเสริมที่คณะ (ดูในข่าวกิจกรรม)</Text>
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
  gpaCard: {
    backgroundGradient: undefined as any,
    backgroundColor: '#420671',
    padding: 20,
    borderRadius: 18,
    marginBottom: 16,
    alignItems: 'center',
  },
  gpaLabel: {
    fontSize: 12,
    color: '#F7E7BB',
    fontFamily: 'Kanit',
    marginBottom: 4,
  },
  gpaValue: {
    fontSize: 40,
    fontWeight: 'bold',
    color: '#F6DC04',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  gpaSub: {
    fontSize: 12,
    color: '#F7E7BB',
    fontFamily: 'Kanit',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 12,
  },
  courseCard: {
    padding: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  courseName: {
    fontSize: 14,
    color: '#420671',
    fontFamily: 'Kanit',
  },
  grade: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#22c55e',
    fontFamily: 'Kanit-Bold',
  },
  tipCard: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: '#652D91',
    marginTop: 12,
  },
  tipText: {
    fontSize: 12,
    color: '#652D91',
    fontFamily: 'Kanit',
  },
});
