import { View, Text, ScrollView, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function RequestsScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>🛠️ แจ้งเรื่อง / ขอเอกสาร</Text>

      <Card style={styles.actionCard}>
        <View style={styles.actionRow}>
          <ActionBtn label="🔧\nแจ้งซ่อม" active />
          <ActionBtn label="📄\nขอเอกสาร" active color="#652D91" borderColor="#652D91" />
          <ActionBtn label="📢\nร้องเรียน" />
        </View>
      </Card>

      <Card style={styles.formCard}>
        <TextInput style={styles.input} placeholder="หัวข้อคำขอ" defaultValue="ขอใบรับรองการเป็นนักศึกษา (ENG)" />
        <TextInput style={styles.input} placeholder="รายละเอียด" defaultValue="ใช้ยื่นขอวีซ่าฝึกงานค่ะ ขอรับแบบ PDF" multiline numberOfLines={3} />
        <TouchableOpacity style={styles.submitBtn}>
          <Text style={styles.submitBtnText}>ส่งคำขอ</Text>
        </TouchableOpacity>
      </Card>

      <View style={styles.sectionTitle}>คำขอของคุณ</View>

      <RequestItem
        id="#RQ-1042"
        title="ขอใบรับรอง ENG"
        status="รอดำเนินการ"
        statusColor="#f59e0b"
        progress={40}
      />
      <RequestItem
        id="#RQ-1039"
        title="แอร์ห้อง 1604 ไม่เย็น"
        status="ช่างรับเรื่อง"
        statusColor="#3b82f6"
        progress={70}
      />
      <RequestItem
        id="#RQ-1031"
        title="ขอ transcript"
        status="เสร็จแล้ว • โหลด PDF"
        statusColor="#22c55e"
      />
    </ScrollView>
  );
}

function ActionBtn({ label, active, color, borderColor }: any) {
  return (
    <TouchableOpacity style={[styles.actionBtn, active && { borderColor, backgroundColor: color && '#fff' }]}>
      <Text style={[styles.actionText, { color }]}>{label}</Text>
    </TouchableOpacity>
  );
}

function RequestItem({ id, title, status, statusColor, progress }: any) {
  return (
    <Card style={styles.requestCard}>
      <View style={styles.requestHeader}>
        <Text style={styles.requestId}>{id}</Text>
        <Text style={styles.requestTitle}>{title}</Text>
        <Text style={[styles.requestStatus, { color: statusColor }]}>{status}</Text>
      </View>
      {progress !== undefined && (
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { backgroundColor: statusColor }]} style={{ width: `${progress}%` }} />
        </View>
      )}
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
  actionCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  actionRow: {
    flexDirection: 'row',
    gap: 8,
  },
  actionBtn: {
    flex: 1,
    paddingVertical: 14,
    paddingHorizontal: 8,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#cbb9e6',
    alignItems: 'center',
  },
  actionText: {
    fontSize: 12,
    color: '#420671',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
    textAlign: 'center',
  },
  formCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  input: {
    width: '100%',
    padding: 12,
    borderWidth: 1,
    borderColor: '#cbb9e6',
    borderRadius: 10,
    marginBottom: 12,
    fontFamily: 'Kanit',
    fontSize: 14,
  },
  submitBtn: {
    backgroundColor: '#420671',
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
  },
  submitBtnText: {
    color: '#fff',
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginTop: 16,
    marginBottom: 10,
  },
  requestCard: {
    padding: 12,
    marginBottom: 10,
  },
  requestHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  requestId: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  requestTitle: {
    fontSize: 13,
    color: '#420671',
    fontFamily: 'Kanit',
    flex: 1,
    marginHorizontal: 8,
  },
  requestStatus: {
    fontSize: 11,
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
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
