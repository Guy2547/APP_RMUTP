import { Stack } from 'expo-router';

export default function ModalLayout() {
  return (
    <Stack>
      <Stack.Screen options={{ headerShown: false, presentation: 'modal' }} />
    </Stack>
  );
}
