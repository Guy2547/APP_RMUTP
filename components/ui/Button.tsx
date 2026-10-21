import { TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';

type ButtonProps = {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'ghost' | 'danger';
  style?: ViewStyle;
  textStyle?: TextStyle;
};

export function Button({ title, onPress, variant = 'primary', style, textStyle }: ButtonProps) {
  const baseStyles = {
    primary: {
      backgroundColor: '#420671',
      borderColor: '#420671',
    },
    ghost: {
      backgroundColor: '#fff',
      borderColor: '#652D91',
    },
    danger: {
      backgroundColor: '#ff4d4d',
      borderColor: '#ff4d4d',
    },
  };

  const textColor = variant === 'primary' ? '#fff' : variant === 'danger' ? '#fff' : '#652D91';

  return (
    <TouchableOpacity
      style={[styles.container, baseStyles[variant], style]}
      onPress={onPress}
    >
      <Text style={[styles.text, { color: textColor }, textStyle]}>{title}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingVertical: 12,
    borderRadius: 10,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 14,
    fontWeight: '600',
    fontFamily: 'Kanit-Bold',
  },
});
