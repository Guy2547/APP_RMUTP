import { Tabs } from 'expo-router';
import { Platform } from 'react-native';
import { useColorScheme } from 'react-native';

export default function AppLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="(app)/index"
        options={{
          title: 'หน้าแรก',
          tabBarIcon: ({ color }: { color: string }) => (
            // Icon placeholder
            null
          ),
        }}
      />
      <Tabs.Screen
        name="(app)/timetable"
        options={{
          title: 'ตารางเรียน',
          tabBarIcon: () => null,
        }}
      />
      <Tabs.Screen
        name="(app)/courses"
        options={{
          title: 'รายวิชา',
          tabBarIcon: () => null,
        }}
      />
      <Tabs.Screen
        name="(app)/news"
        options={{
          title: 'ข่าว',
          tabBarIcon: () => null,
        }}
      />
      <Tabs.Screen
        name="(app)/profile"
        options={{
          title: 'ฉัน',
          tabBarIcon: () => null,
        }}
      />
    </Tabs>
  );
}
