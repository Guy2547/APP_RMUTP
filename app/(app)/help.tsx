import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from 'react-native';
import { Card } from '@/components/ui/Card';

export default function HelpScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>❓ ช่วยเหลือ / ติดต่อ</Text>

      <View style={styles.contactRow}>
        <ContactBtn icon="📞" title="ทะเบียน" phone="02-665-3777" />
        <ContactBtn icon="💻" title="IT Helpdesk" phone="02-665-3888" />
      </View>

      <Card style={styles.faqCard}>
        <Text style={styles.faqTitle}>คำถามพบบ่อย</Text>
        <FaqItem question="ลืมรหัสผ่าน RMUTP Portal ทำยังไง?" answer="กดลืมรหัสที่ portal.rmutp.ac.th หรือติดต่อสำนักวิทยบริการพร้อมบัตร นศ." />
        <FaqItem question="ขอ transcript นานไหม?" answer="แบบ PDF 1–2 วันทำการ ฉบับจริง 3–5 วัน รับที่งานทะเบียน" />
        <FaqItem question="ติดต่ออาจารย์ที่ปรึกษา?" answer="ดูเบอร์โทรและเวลาพบที่หน้าโปรไฟล์อาจารย์ หรือติดต่อผ่านงานทะเบียนภาควิชา" />
      </Card>

      <TouchableOpacity style={styles.mapBtn}>
        <Text style={styles.mapBtnText}>🗺️ แผนที่ศูนย์เทเวศร์ / โชติเวช / พระนครเหนือ...</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

function ContactBtn({ icon, title, phone }: any) {
  return (
    <TouchableOpacity style={styles.contactBtn} onPress={() => {}}>
      <Text style={styles.contactIcon}>{icon}</Text>
      <Text style={styles.contactTitle}>{title}</Text>
      <Text style={styles.contactPhone}>{phone}</Text>
    </TouchableOpacity>
  );
}

function FaqItem({ question, answer }: any) {
  return (
    <View style={styles.faqItem} key={question}>
      <Text style={styles.faqQuestion}>{question}</Text>
      <Text style={styles.faqAnswer}>{answer}</Text>
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
  contactRow: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 16,
  },
  contactBtn: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  contactIcon: {
    fontSize: 24,
    marginBottom: 4,
  },
  contactTitle: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
  },
  contactPhone: {
    fontSize: 11,
    color: '#64748b',
    fontFamily: 'Kanit',
  },
  faqCard: {
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
  faqTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 10,
  },
  faqItem: {
    backgroundColor: '#f8fafc',
    padding: 10,
    borderRadius: 10,
    marginBottom: 8,
  },
  faqQuestion: {
    fontSize: 12,
    fontWeight: '600',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 4,
  },
  faqAnswer: {
    fontSize: 11,
    color: '#64748b',
    fontFamily: 'Kanit',
  },
  mapBtn: {
    backgroundColor: '#fff',
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  mapBtnText: {
    fontSize: 13,
    color: '#420671',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
});
