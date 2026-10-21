import { Stack } from 'expo-router';
import { useEffect, useState } from 'react';
import { Platform, StatusBar, SafeAreaView, View } from 'react-native';
import { Font } from 'expo-font';
import { useColorScheme } from 'react-native';
import { SplashScreen } from 'expo-splash-screen';
import { Kanit_400Regular, Kanit_700Bold } from '@expo-google-fonts/kanit';

export default function RootLayout() {
  const [fontLoaded, setFontLoaded] = useState(false);

  useEffect(() => {
    async function loadFonts() {
      await Font.loadAsync({
        Kanit: Kanit_400Regular,
        'Kanit-Bold': Kanit_700Bold,
      });
      setFontLoaded(true);
    }
    loadFonts();
  }, []);

  if (!fontLoaded) {
    return null;
  }

  return (
    <Stack>
      <Stack.Screen options={{ headerShown: false }} />
    </Stack>
  );
}
