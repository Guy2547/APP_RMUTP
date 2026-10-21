import { View, Text, ScrollView, StyleSheet, TextInput } from 'react-native';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';

export default function CoursesScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>📚 รายวิชาของฉัน (6)</Text>

      <TextInput
        style={styles.searchInput}
        placeholder="ค้นหาวิชา / รหัสวิชา..."
      />

      <View style={styles.courseList}>
        <CourseItem
          code="ENGCE302"
          name="ระบบฐานข้อมูล"
          status="งานค้าง 1 • คะแนนเก็บ 28/40"
          instructor="อ.สุรชัย"
          progress={70}
          color="#652D91"
        />
        <CourseItem
          code="ENGCE305"
          name="เครือข่ายคอมพิวเตอร์"
          status="งานค้าง 1 • Lab สัปดาห์ 6"
          instructor="ผศ.นภัส"
          progress={45}
          color="#F6DC04"
        />
        <CourseItem
          code="GEN101"
          name="ภาษาอังกฤษเพื่ออาชีพ"
          status="ไม่มีงานค้าง • เรียนออนไลน์"
          instructor=""
          progress={0}
          color="#94a3b8"
        />
      </View>
    </ScrollView>
  );
}

function CourseItem({ code, name, status, instructor, progress, color }: any) {
  return (
    <Card style={styles.courseCard}>
      <View style={styles.courseHeader}>
        <Text style={styles.courseCode}>{code}</Text>
        <Text style={styles.courseName}>{name}</Text>
      </View>
      <Text style={styles.courseStatus}>{status}</Text>
      {instructor && (
        <Text style={styles.courseInstructor}>{instructor}</Text>
      )}
      <View style={styles.progressContainer}>
        <View style={[styles.progressBar, { backgroundColor: color }]} style={{ width: `${progress}%` }} />
      </View>
    </Card>
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
  searchInput: {
    width: '100%',
    padding: 12,
    borderWidth: 1,
    borderColor: '#cbb9e6',
    borderRadius: 12,
    marginBottom: 16,
    fontFamily: 'Kanit',
    fontSize: 14,
  },
  courseList: {
    gap: 10,
  },
  courseCard: {
    padding: 14,
  },
  courseHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  courseCode: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#652D91',
    fontFamily: 'Kanit-Bold',
  },
  courseName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  courseStatus: {
    fontSize: 12,
    color: '#652D91',
    fontFamily: 'Kanit',
    marginBottom: 6,
  },
  courseInstructor: {
    fontSize: 12,
    color: '#420671',
    fontFamily: 'Kanit',
    marginBottom: 8,
  },
  progressContainer: {
    height: 6,
    backgroundColor: '#e2e8f0',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    borderRadius: 3,
  },
});
