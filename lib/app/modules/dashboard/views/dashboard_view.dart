import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../downloaded_videos/views/downloaded_videos_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final List<Widget> pages = [
      const HomeView(),
      const DownloadedVideosView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: pages,
      )),
      bottomNavigationBar: SafeArea(
        child: Obx(() => CurvedNavigationBar(
          index: controller.selectedIndex.value,
          backgroundColor: const Color(0xFF12121A), // Matches Scaffold background to blend in
          color: const Color(0xFF1A1A2E), // Navigation bar color
          buttonBackgroundColor: theme.colorScheme.primary, // Floating button color
          height: 60,
          animationDuration: const Duration(milliseconds: 300),
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.home_rounded, color: Colors.white),
              label: 'الرئيسية',
              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.download_rounded, color: Colors.white),
              label: 'التحميلات',
              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.person_rounded, color: Colors.white),
              label: 'حسابي',
              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          onTap: (index) => controller.changeIndex(index),
        )),
      ),
    );
  }
}
