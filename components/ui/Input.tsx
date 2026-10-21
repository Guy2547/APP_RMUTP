import { TextInput, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';

type InputProps = {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  secureTextEntry?: boolean;
  placeholder?: string;
  style?: ViewStyle;
  labelStyle?: TextStyle;
};

export function Input({ label, value, onChangeText, secureTextEntry, placeholder, style, labelStyle }: InputProps) {
  return (
    <>
      <Text style={[styles.label, labelStyle]}>{label}</Text>
      <TextInput
        style={[styles.input, style]}
        value={value}
        onChangeText={onChangeText}
        secureTextEntry={secureTextEntry}
        placeholder={placeholder}
      />
    </>
  );
}

const styles = StyleSheet.create({
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
});
