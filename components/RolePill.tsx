import { TouchableOpacity, Text, StyleSheet, ViewStyle } from 'react-native';

type RolePillProps = {
  role: 'student' | 'teacher';
  active: boolean;
  onPress: () => void;
  style?: ViewStyle;
};

export function RolePill({ role, active, onPress, style }: RolePillProps) {
  const label = role === 'student' ? '🎓 นักศึกษา' : '👩‍🏫 อาจารย์';

  return (
    <TouchableOpacity
      style={[styles.pill, active && styles.pillActive, style]}
      onPress={onPress}
    >
      <Text style={[styles.text, active && styles.textActive]}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  pill: {
    flex: 1,
    paddingVertical: 8,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#cbb9e6',
    alignItems: 'center',
  },
  pillActive: {
    backgroundColor: '#F6DC04',
    borderColor: '#F6DC04',
  },
  text: {
    fontSize: 12,
    color: '#652D91',
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
  textActive: {
    color: '#420671',
  },
});
