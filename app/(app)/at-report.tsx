import { View, Text, ScrollView, StyleSheet } from 'react-native';

export default function ATReportScreen() {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>รายงานสรุปการเข้าร่วมกิจกรรม</Text>

      <View style={styles.summaryRow}>
        <StatBox label="กิจกรรมทั้งหมด" value="7 กิจกรรม" color="#420671" />
        <StatBox label="รวม" value="21 ครั้ง" color="#420671" />
        <StatBox label="กิจกรรมที่ยืนยัน" value="5 กิจกรรม" color="#420671" />
        <StatBox label="รวม" value="15 ครั้ง" color="#420671" />
        <StatBox label="ยังไม่ได้ยืนยัน" value="0 กิจกรรม" color="#ef4444" />
        <StatBox label="รวม" value="0 ครั้ง" color="#ef4444" />
      </View>

      <View style={styles.tableContainer}>
        <Table header={['กิจกรรมมหาวิทยาลัย', '7 กิจกรรม', '5 กิจกรรม', '0 กิจกรรม']} rows={[
          ['รวม', '21 ครั้ง', '15 ครั้ง', '0 ครั้ง'],
          ['กิจกรรมปฐมนิเทศ', '4 กิจกรรม', '5 กิจกรรม', '0 กิจกรรม'],
          ['(1) ปฐมนิเทศนักศึกษาใหม่ Year1', '1 กิจกรรม', '>= 1 กิจกรรม', '1 กิจกรรม'],
        ]} />

        <View style={styles.sectionTitle}>กิจกรรมพัฒนาศักยภาพ</View>
        <Table header={['กิจกรรมพัฒนาศักยภาพ', '4 กิจกรรม', '5 กิจกรรม', '1 กิจกรรม']} rows={[
          ['รวม', '11 ครั้ง', '15 ครั้ง', '4 ครั้ง'],
          ['กิจกรรมทางวิชาการ', '1 กิจกรรม', '>= 1 กิจกรรม', ''],
          ['กิจกรรมทักษะด้านภาษา', '3 กิจกรรม', '>= 1 กิจกรรม', ''],
        ]} />
      </View>
    </ScrollView>
  );
}

function StatBox({ label, value, color }: any) {
  return (
    <View style={[styles.statBox, { borderTopColor: color }]}>
      <Text style={[styles.statLabel, { color }]}>{label}</Text>
      <Text style={[styles.statValue, { color, fontWeight: 'bold' }]}>{value}</Text>
    </View>
  );
}

function Table({ header, rows }: any) {
  return (
    <View style={styles.table}>
      <View style={styles.tableHeader}>
        {header.map((h: string) => (
          <Text key={h} style={styles.headerCell}>{h}</Text>
        ))}
      </View>
      <View style={styles.tableBody}>
        {rows.map((row: string[], i: number) => (
          <View key={i} style={styles.tableRow}>
            {row.map((cell: string, j: number) => (
              <Text key={j} style={[styles.cell, j === 0 && { fontWeight: '600' }]}>{cell}</Text>
            ))}
          </View>
        ))}
      </View>
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
    textAlign: 'center',
  },
  summaryRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
    marginBottom: 16,
  },
  statBox: {
    flex: 1,
    minWidth: '30%',
    backgroundColor: '#fff',
    padding: 10,
    borderRadius: 10,
    borderTopWidth: 3,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 2,
  },
  statLabel: {
    fontSize: 10,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
    textAlign: 'center',
    marginBottom: 4,
  },
  statValue: {
    fontSize: 14,
    color: '#420671',
    fontFamily: 'Kanit',
    textAlign: 'center',
  },
  tableContainer: {
    gap: 12,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 6,
  },
  table: {
    backgroundColor: '#fff',
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 3,
  },
  tableHeader: {
    flexDirection: 'row',
    backgroundColor: '#652D91',
    padding: 8,
  },
  headerCell: {
    flex: 1,
    fontSize: 11,
    color: '#fff',
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
    textAlign: 'center',
    paddingVertical: 6,
  },
  tableBody: {
    padding: 4,
  },
  tableRow: {
    flexDirection: 'row',
    paddingVertical: 6,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  cell: {
    flex: 1,
    fontSize: 11,
    color: '#420671',
    fontFamily: 'Kanit',
    textAlign: 'center',
    paddingHorizontal: 4,
  },
});
