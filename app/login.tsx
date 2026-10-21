import { useRouter } from 'expo-router';
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useColorScheme } from 'react-native';

export default function LoginScreen() {
  const router = useRouter();
  const [studentId, setStudentId] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<'student' | 'teacher'>('student');

  const handleLogin = () => {
    if (!studentId || !password) {
      Alert.alert('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }
    router.replace('/(app)');
  };

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Text style={styles.logoText}>RMUTP</Text>
        <Text style={styles.title}>Activity Transcript System</Text>
      </View>

      <View style={styles.formContainer}>
        <Text style={styles.subtitle}>เข้าสู่ระบบด้วยรหัสนักศึกษา</Text>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัสนักศึกษา</Text>
          <TextInput
            style={styles.input}
            value={studentId}
            onChangeText={setStudentId}
            placeholder="เช่น 056860405008-4"
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>รหัสผ่าน AT-Code</Text>
          <TextInput
            style={styles.input}
            value={password}
            onChangeText={setPassword}
            placeholder="กรอกรหัส AT-Code"
            secureTextEntry
          />
        </View>

        <View style={styles.roleSelector}>
          <TouchableOpacity
            style={[styles.roleButton, role === 'student' && styles.roleButtonActive]}
            onPress={() => setRole('student')}
          >
            <Text style={[styles.roleText, role === 'student' && styles.roleTextActive]}>
              🎓 นักศึกษา
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.roleButton, role === 'teacher' && styles.roleButtonActive]}
            onPress={() => setRole('teacher')}
          >
            <Text style={[styles.roleText, role === 'teacher' && styles.roleTextActive]}>
              👩‍🏫 อาจารย์
            </Text>
          </TouchableOpacity>
        </View>

        <TouchableOpacity style={styles.loginButton} onPress={handleLogin}>
          <Text style={styles.loginButtonText}>Login</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.cancelButton} onPress={() => {}}>
          <Text style={styles.cancelButtonText}>Cancel</Text>
        </TouchableOpacity>
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
  logoContainer: {
    alignItems: 'center',
    marginBottom: 32,
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
    color: '#fff',
    marginTop: 8,
    fontFamily: 'Kanit-Bold',
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 24,
    marginHorizontal: 0,
    flex: 1,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#420671',
    textAlign: 'center',
    marginBottom: 24,
    fontFamily: 'Kanit-Bold',
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
  roleSelector: {
    flexDirection: 'row',
    gap: 8,
    marginBottom: 20,
  },
  roleButton: {
    flex: 1,
    paddingVertical: 10,
    borderWidth: 2,
    borderColor: '#cbb9e6',
    borderRadius: 10,
    alignItems: 'center',
  },
  roleButtonActive: {
    borderColor: '#F6DC04',
    backgroundColor: '#F6DC04',
  },
  roleText: {
    fontSize: 13,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
  roleTextActive: {
    color: '#420671',
  },
  loginButton: {
    backgroundColor: '#420671',
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 8,
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
    fontFamily: 'Kanit-Bold',
  },
  cancelButton: {
    paddingVertical: 10,
    borderRadius: 10,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: '#652D91',
    fontSize: 13,
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
});
