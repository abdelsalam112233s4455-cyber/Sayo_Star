import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/rooms.dart';
import '../home/me.dart';
import '../home/chat.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String email = FirebaseAuth.instance.currentUser?.email ?? '';

  int currentIndex = 1;

  final List<Widget> pages = [
    const Rooms(),
    const Chat(),
    Me(),
  ];

  @override
  void initState() {
    super.initState();
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIndex = prefs.getInt('last_home_page');

    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < pages.length) {
      if (!mounted) return;

      setState(() {
        currentIndex = savedIndex;
      });
    }
  }

  Future<void> _saveCurrentPage(int index) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_home_page', index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color barColor = isDark
        ? const Color(0xFF181A1F)
        : Colors.white;

    final Color selectedColor = isDark
        ? const Color(0xFFB44BFF)
        : const Color(0xFF9C27B0);

    final Color unselectedColor = isDark
        ? const Color(0xFF858A95)
        : const Color(0xFF9EA3A8);

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: barColor,
        currentIndex: currentIndex,
        elevation: 12,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          _saveCurrentPage(index);
        },

        items: [
          BottomNavigationBarItem(
            icon: _buildTab(
              index: 0,
              icon: Icons.people_outline,
              title: 'الغرف',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            label: 'غرف الدردشة',
          ),

          BottomNavigationBarItem(
            icon: _buildTab(
              index: 1,
              icon: Icons.message_outlined,
              title: 'الرسائل',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            label: 'الرسائل الأصدقاء',
          ),

          BottomNavigationBarItem(
            icon: _buildTab(
              index: 2,
              icon: Icons.person_outline,
              title: 'أنا',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
            label: 'ملفي الشخصي',
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String title,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final bool isSelected = currentIndex == index;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 25,
          color: isSelected
              ? selectedColor
              : unselectedColor,
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight:
            isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? selectedColor
                : unselectedColor,
          ),
        ),
      ],
    );
  }
}