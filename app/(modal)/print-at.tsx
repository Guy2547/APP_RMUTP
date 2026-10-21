import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function PrintATScreen() {
  return (
    <View style={styles.container}>
      <View style={styles.formCard}>
        <Text style={styles.title}>พิมพ์เบื้ม AT-Code ระบุโค้ดกิจกรรม</Text>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัสนักศึกษา</Text>
          <Text style={styles.inputValue}>056860405008-4</Text>
        </View>
        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัส AT-Code</Text>
          <Text style={styles.inputPlaceholder}>กรอกรหัส AT-Code</Text>
        </View>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.btnPrimary} onPress={() => {}}>
            <Text style={styles.btnText}>พิมพ์เบื้ม</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.btnGhost} onPress={() => {}}>
            <Text style={styles.btnTextGhost}>Cancel</Text>
          </TouchableOpacity>
        </View>
        <Text style={styles.footer}>
          รหัสนักศึกษา : 056860405008-4 | ปี : นายสมใจ รวยรุ่ง | คณะ : วิศวกรรมศาสตร์
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#420671',
    padding: 24,
    justifyContent: 'center',
  },
  formCard: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 24,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#420671',
    fontFamily: 'Kanit-Bold',
    marginBottom: 20,
  },
  inputGroup: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#420671',
    marginBottom: 6,
    fontFamily: 'Kanit-Bold',
  },
  inputValue: {
    fontSize: 15,
    color: '#420671',
    fontFamily: 'Kanit',
  },
  inputPlaceholder: {
    fontSize: 15,
    color: '#94a3b8',
    fontFamily: 'Kanit',
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 8,
  },
  btnPrimary: {
    flex: 1,
    backgroundColor: '#420671',
    paddingVertical: 11,
    borderRadius: 10,
    alignItems: 'center',
  },
  btnText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
  },
  btnGhost: {
    flex: 1,
    borderWidth: 2,
    borderColor: '#652D91',
    paddingVertical: 11,
    borderRadius: 10,
    alignItems: 'center',
  },
  btnTextGhost: {
    color: '#652D91',
    fontSize: 13,
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
  },
  footer: {
    fontSize: 11,
    color: '#94a3b8',
    fontFamily: 'Kanit',
    textAlign: 'center',
    marginTop: 12,
  },
});
