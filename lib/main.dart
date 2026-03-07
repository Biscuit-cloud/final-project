import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:provider/provider.dart';           
import 'package:project/History.dart';
import 'package:project/MainPage.dart';
import 'package:project/weight_provider.dart';     

// 1. เพิ่มบรรทัดนี้เข้ามา (ถ้ายังไม่มีไฟล์นี้ ให้ดูข้อ 2 ด้านล่างครับ)
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. แก้ไขบรรทัดนี้ให้มี options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  // ครอบแอปด้วย Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeightProvider(),
      child: const BMISmartScaleApp(),
    ),
  );
}

// โค้ดส่วน class BMISmartScaleApp และด้านล่าง ปล่อยไว้เหมือนเดิมได้เลยครับ...

class BMISmartScaleApp extends StatelessWidget {
  const BMISmartScaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurpleAccent,
        fontFamily: 'Kanit',
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; 

  final List<Widget> _pages = [
    const HistoryPage(), 
    const HomePage(),    
    // const ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF7B61FF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 30),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            const SizedBox(width: 40), 
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 30),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กำลังพัฒนาหน้า Profile...')),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => setState(() => _selectedIndex = 1),
        child: const Icon(Icons.home, color: Color(0xFF7B61FF), size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}