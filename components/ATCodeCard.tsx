import { TouchableOpacity, View, Text, StyleSheet } from 'react-native';

type ATCodeCardProps = {
  icon: string;
  title: string;
  subtitle?: string;
  onPress: () => void;
};

export function ATCodeCard({ icon, title, subtitle, onPress }: ATCodeCardProps) {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <Text style={styles.icon}>{icon}</Text>
      <Text style={styles.title}>{title}</Text>
      {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 20,
    padding: 16,
    borderWidth: 2,
    borderColor: '#e9d27a',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 4,
  },
  icon: {
    fontSize: 46,
    marginBottom: 10,
  },
  title: {
    fontSize: 15,
    fontWeight: '700',
    color: '#420671',
    textAlign: 'center',
    fontFamily: 'Kanit-Bold',
    lineHeight: 20,
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 12,
    color: '#652D91',
    textAlign: 'center',
    fontFamily: 'Kanit',
  },
});
