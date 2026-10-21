import { useRouter } from 'expo-router';
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';

export default function ATLoginScreen() {
  const router = useRouter();
  const [studentId, setStudentId] = useState('056860405008-4');
  const [atCode, setAtCode] = useState('');

  const handleLogin = () => {
    if (!studentId || !atCode) {
      Alert.alert('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }
    router.replace('/(app)');
  };

  return (
    <View style={styles.container}>
      <View style={styles.formContainer}>
        <View style={styles.logoContainer}>
          <Text style={styles.logoText}>RMUTP</Text>
          <Text style={styles.title}>Activity Transcript System</Text>
          <Text style={styles.subtitle}>เข้าสู่ระบบด้วยรหัสนักศึกษา และรหัสผ่าน AT-Code</Text>
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัสนักศึกษา</Text>
          <TextInput
            style={styles.input}
            value={studentId}
            onChangeText={setStudentId}
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัส AT-Code</Text>
          <TextInput
            style={styles.input}
            value={atCode}
            onChangeText={setAtCode}
            secureTextEntry
          />
        </View>

        <View style={styles.buttonRow}>
          <TouchableOpacity style={styles.btnPrimary} onPress={handleLogin}>
            <Text style={styles.btnText}>Login</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.btnGhost} onPress={() => router.replace('/login')}>
            <Text style={styles.btnTextGhost}>Cancel</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#420671',
    padding: 24,
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 24,
    flex: 1,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 24,
  },
  logoText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#F6DC04',
    fontFamily: 'Kanit-Bold',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#420671',
    marginTop: 8,
    fontFamily: 'Kanit-Bold',
  },
  subtitle: {
    fontSize: 13,
    color: '#652D91',
    textAlign: 'center',
    marginTop: 6,
    marginBottom: 24,
    fontFamily: 'Kanit',
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
  input: {
    width: '100%',
    padding: 12,
    borderWidth: 2,
    borderColor: '#cbb9e6',
    borderRadius: 12,
    fontSize: 15,
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
});
